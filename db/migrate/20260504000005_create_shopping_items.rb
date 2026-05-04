class CreateShoppingItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_items do |t|
      t.references :shopping_list, null: false, foreign_key: true
      t.string :name, null: false
      t.string :category
      t.boolean :purchased, null: false, default: false
      t.timestamps
    end

    add_index :shopping_items, [ :shopping_list_id, :name ], unique: true
  end
end
