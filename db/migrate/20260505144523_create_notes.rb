class CreateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :notes do |t|
      t.text :content, null: false
      t.string :visibility, null: false, default: "private"
      t.string :status, null: false, default: "pending"
      t.references :telegram_user, null: false, foreign_key: true
      t.references :household, null: false, foreign_key: true
      t.references :note_category, null: true, foreign_key: true

      t.timestamps
    end
  end
end
