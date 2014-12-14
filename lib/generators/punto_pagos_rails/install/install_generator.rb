class PuntoPagosRails::InstallGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_resource_model
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.map(&:to_s)
    models.include?(name.classify) ? add_amount_attribute_to_resources : create_resource
  end

  def extend_resource_abilities
    line = "class #{name.classify} < ActiveRecord::Base"
    gsub_file "app/models/#{name}.rb", /(#{Regexp.escape(line)})/mi do |match|
      "#{match}\n  include PuntoPagosRails::ResourceExtension\n"
    end
  end

  def copy_migrations
    rake "railties:install:migrations"
  end

  def create_initializer
    template "puntopagos.yml", "config/puntopagos.yml"
    template "punto_pagos_rails.rb", "config/initializers/punto_pagos_rails.rb"
  end

  def mount_routes
    line = "Rails.application.routes.draw do"
    gsub_file "config/routes.rb", /(#{Regexp.escape(line)})/mi do |match|
      "#{match}\n mount PuntoPagosRails::Engine => '/'\n"
    end
  end

  def copy_views
    copy_file "success.html.erb", "app/views/punto_pagos_rails/transactions/success.html.erb"
    copy_file "error.html.erb", "app/views/punto_pagos_rails/transactions/error.html.erb"
  end

  private

    def add_amount_attribute_to_resources
      generate "migration add_amount_to_#{name.tableize} amount:integer"
    end

    def create_resource
      generate "model #{name.classify} amount:integer --no-fixture"
    end
end
