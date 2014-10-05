class PuntoPagosRails::InstallGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_resource_model
    model_name = name.downcase.camelize.singularize
    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.map(&:to_s)

    if models.include?(model_name)
      add_amount_attribute_to_resources(model_name)
    else
      create_resource(model_name)
    end
  end

  def copy_migrations
    rake "railties:install:migrations"
  end

  def create_initializer
    puts 'TODO: create_initializer'
  end

  private

    def add_amount_attribute_to_resources _model_name
      table_name = _model_name.tableize
      generate "migration add_amount_to_#{table_name} amount:integer"
    end

    def create_resource _model_name
      generate "model #{_model_name} amount:integer"
    end
end
