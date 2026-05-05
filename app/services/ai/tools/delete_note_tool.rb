module Ai
  module Tools
    class DeleteNoteTool < BaseTool
      def self.tool_name = "delete_note"
      def self.description = <<~DESC
        Delete a note by its ID. Only the note's owner can delete it.
        Use list_notes first if you need to find the note_id.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "note_id" => { "type" => "integer", "description" => "ID of the note to delete" }
          },
          "required" => [ "note_id" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        note = household.notes.find_by(id: arguments["note_id"])
        return ToolResult.err("Note not found.") unless note
        return ToolResult.err("Not authorised.") unless note.telegram_user_id == context.telegram_user.id

        note.destroy!
        ToolResult.ok("Note deleted.")
      end
    end
  end
end
