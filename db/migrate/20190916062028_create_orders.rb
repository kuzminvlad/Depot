# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :name
      t.text :adress
      t.string :email
      t.string :pay_type

      t.timestamps
    end
  end
end
