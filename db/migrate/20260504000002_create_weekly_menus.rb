class CreateWeeklyMenus < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_menus do |t|
      t.references :household, null: false, foreign_key: true
      t.date :week_start_date, null: false
      t.text :notes

      t.timestamps
    end

    add_index :weekly_menus, [ :household_id, :week_start_date ], unique: true
  end
end
