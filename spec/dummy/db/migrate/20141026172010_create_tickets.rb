class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :amount
      t.string :payment_state
      t.string :message

      t.timestamps null: false
    end
  end
end
