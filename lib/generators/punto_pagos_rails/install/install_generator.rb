class PuntoPagosRails::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_transactions_table
    generate("migration create_punto_pagos_rails_transactions")
    new_migration_path = Dir["#{Rails.application.root}/db/migrate/*.rb"].last
    template "transactions_migration.rb", new_migration_path, force: true
  end

  def create_initializer
    template "puntopagos.yml", "config/puntopagos.yml"
  end
end
