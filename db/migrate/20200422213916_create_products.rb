class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :title, null: false
      t.string :description
      t.integer :units_available, null: false, default: 0
      t.decimal :unit_price, null: false
      t.boolean :hidden, null: false, default: false

      t.timestamps
    end
  end
end
