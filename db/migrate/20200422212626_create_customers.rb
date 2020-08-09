class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.bigint :document_number, null: false, unique: true
      t.bigint :phone_number, null: false
      t.string :address, null: false

      t.timestamps
    end
  end
end
