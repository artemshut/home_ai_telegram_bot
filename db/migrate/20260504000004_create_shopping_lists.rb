class CreateShoppingLists < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_lists do |t|
      t.references :household, null: false, foreign_key: true
      t.references :weekly_menu, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
