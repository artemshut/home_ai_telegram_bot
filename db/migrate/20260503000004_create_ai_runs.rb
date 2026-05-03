class CreateAiRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_runs do |t|
      t.references :telegram_user, null: true, foreign_key: true
      t.references :telegram_message, null: true, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :model, null: false
      t.text :system_prompt
      t.jsonb :messages, null: false, default: []
      t.jsonb :response, null: false, default: {}
      t.integer :input_tokens
      t.integer :output_tokens
      t.integer :cache_creation_tokens
      t.integer :cache_read_tokens
      t.integer :duration_ms
      t.text :error

      t.timestamps
    end

    add_index :ai_runs, :status
  end
end
