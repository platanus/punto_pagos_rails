class CreatePuntoPagosRailsTransactions < ActiveRecord::Migration
  def change
    create_table :punto_pagos_rails_transactions do |t|
      t.references :payable, polymorphic: true
      t.string :token
      t.integer :amount
      t.string :error
      t.string :state

      t.timestamps
    end

    add_index(:punto_pagos_rails_transactions,
      [:payable_id, :payable_type],
      name: "index_punto_pagos_rails_transactions_on_payable",
      unique: true)
  end
end
