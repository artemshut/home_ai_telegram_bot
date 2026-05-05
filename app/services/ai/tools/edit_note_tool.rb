module Ai
  module Tools
    class EditNoteTool < BaseTool
      def self.tool_name = "edit_note"
      def self.description = <<~DESC
        Edit an existing note. Only the note's owner can edit it.
        Provide note_id plus any combination of content, category_name, or visibility to update.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "note_id"       => { "type" => "integer", "description" => "ID of the note to edit" },
            "content"       => { "type" => "string",  "description" => "New note content" },
            "category_name" => { "type" => "string",  "description" => "New category name (created if it doesn't exist)" },
            "visibility"    => { "type" => "string",  "enum" => %w[private public], "description" => "New visibility" }
          },
          "required" => [ "note_id" ]
        }
      end

      private

      def call(arguments, context)
        content       = arguments["content"]
        category_name = arguments["category_name"]
        visibility    = arguments["visibility"]

        unless content.present? || category_name.present? || visibility.present?
          return ToolResult.err("Provide at least one of: content, category_name, visibility.")
        end

        note = Note.find_by(id: arguments["note_id"])
        return ToolResult.err("Note not found.") unless note
        return ToolResult.err("Not authorised.") unless note.telegram_user_id == context.telegram_user.id

        changes = []
        attrs   = {}

        if content.present?
          attrs[:content] = content
          changes << "content updated"
        end

        if visibility.present?
          attrs[:visibility] = visibility
          changes << "visibility → #{visibility}"
        end

        if category_name.present?
          category = note.household.note_categories.find_or_create_by!(name: category_name.strip)
          attrs[:note_category] = category
          changes << "category → #{category.name}"
        end

        note.update!(attrs)
        ToolResult.ok("Note updated: #{changes.join(", ")}.")
      rescue ActiveRecord::RecordInvalid => e
        ToolResult.err("Could not update note: #{e.message}")
      end
    end
  end
end
