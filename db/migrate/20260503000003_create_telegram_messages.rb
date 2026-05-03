class CreateTelegramMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :telegram_messages do |t|
      t.bigint :update_id, null: false
      t.references :telegram_user, null: true, foreign_key: true
      t.bigint :chat_id, null: false
      t.bigint :message_id, null: false
      t.text :text
      t.jsonb :raw_update, null: false, default: {}
      t.string :direction, null: false, default: "inbound"
      t.timestamps
    end
    add_index :telegram_messages, :update_id, unique: true
  end
end
