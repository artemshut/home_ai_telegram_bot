class MakeNoteVisibilityNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :notes, :visibility, true
    change_column_default :notes, :visibility, from: "private", to: nil
  end
end
