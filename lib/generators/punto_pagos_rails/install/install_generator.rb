class PuntoPagosRails::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

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
      "#{match}\n  mount PuntoPagosRails::Engine => \"/\"\n"
    end
  end
end
