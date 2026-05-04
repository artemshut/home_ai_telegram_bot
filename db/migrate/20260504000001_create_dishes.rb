class CreateDishes < ActiveRecord::Migration[8.1]
  def change
    create_table :dishes do |t|
      t.references :household, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :dishes, [ :household_id, :name ], unique: true
  end
end
