class CreatePuntoPagosRailsTransactions < ActiveRecord::Migration
  def change
    create_table :punto_pagos_rails_transactions do |t|
      t.integer :resource_id
      t.string :token
      t.integer :amount
      t.string :error
      t.string :state

      t.timestamps
    end
  end
end
