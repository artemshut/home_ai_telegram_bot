class CreateNoteCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :note_categories do |t|
      t.string :name, null: false
      t.references :household, null: false, foreign_key: true

      t.timestamps
    end

    add_index :note_categories, [ :household_id, :name ], unique: true
  end
end
