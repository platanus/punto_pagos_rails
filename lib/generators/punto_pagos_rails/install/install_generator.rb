class PuntoPagosRails::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_migrations
    rake "railties:install:migrations"
  end

  def create_initializer
    template "puntopagos.yml", "config/puntopagos.yml"
  end
end
