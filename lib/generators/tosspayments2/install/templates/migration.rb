# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.string :order_id, null: false
      t.integer :amount, null: false
      t.string :status, null: false
      t.string :transaction_id
      t.timestamps
    end
    add_index :payments, :order_id, unique: true
  end
end
