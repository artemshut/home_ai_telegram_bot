class AddPendingEditNoteIdToTelegramUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :telegram_users, :pending_edit_note_id, :integer
  end
end
