class CreateMeals < ActiveRecord::Migration[8.1]
  def change
    create_table :meals do |t|
      t.references :weekly_menu, null: false, foreign_key: true
      t.references :dish, null: false, foreign_key: true
      t.string :day_of_week, null: false
      t.string :meal_type, null: false

      t.timestamps
    end

    add_index :meals, [ :weekly_menu_id, :day_of_week, :meal_type ], unique: true
  end
end
