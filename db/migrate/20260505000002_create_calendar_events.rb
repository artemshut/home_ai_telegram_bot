class CreateCalendarEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :calendar_events do |t|
      t.references :household, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :location
      t.string :calendar_id, default: "primary", null: false
      t.string :status, default: "pending", null: false
      t.string :google_event_id

      t.timestamps
    end

    add_index :calendar_events, [ :household_id, :status ]
    add_index :calendar_events, :start_at
  end
end
