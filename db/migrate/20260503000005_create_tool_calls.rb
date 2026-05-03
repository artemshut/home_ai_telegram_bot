class CreateToolCalls < ActiveRecord::Migration[8.1]
  def change
    create_table :tool_calls do |t|
      t.references :ai_run, null: false, foreign_key: true
      t.string :tool_name, null: false
      t.jsonb :arguments, null: false, default: {}
      t.jsonb :result, null: false, default: {}
      t.string :status, null: false, default: "pending"
      t.text :error
      t.integer :duration_ms

      t.timestamps
    end

    add_index :tool_calls, :status
  end
end
