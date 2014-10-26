class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :amount

      t.timestamps
    end
  end
end
