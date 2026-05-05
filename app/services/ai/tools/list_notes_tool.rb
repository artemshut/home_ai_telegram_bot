module Ai
  module Tools
    class ListNotesTool < BaseTool
      def self.tool_name = "list_notes"
      def self.description = <<~DESC
        List notes visible to the current user: their own private notes plus all public household notes.
        Optionally filter by keyword or category. Never returns another user's private notes.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "query"         => { "type" => "string", "description" => "Keyword to search in note content" },
            "category_name" => { "type" => "string", "description" => "Filter by category name (case-insensitive)" },
            "limit"         => { "type" => "integer", "description" => "Max notes to return (default 20)" }
          },
          "required" => []
        }
      end

      private

      def call(arguments, context)
        user      = context.telegram_user
        household = user&.household
        return ToolResult.err("No household found for this user.") unless household

        limit = [ (arguments["limit"] || 20).to_i, 100 ].min
        notes = household.notes.visible_to(user).includes(:note_category, :telegram_user).order(created_at: :desc)

        if arguments["query"].present?
          notes = notes.where("content ILIKE ?", "%#{arguments["query"]}%")
        end

        if arguments["category_name"].present?
          notes = notes.joins(:note_category)
                       .where("LOWER(note_categories.name) = ?", arguments["category_name"].downcase)
        end

        notes = notes.limit(limit)

        return ToolResult.ok("No notes found.") if notes.empty?

        result = notes.map do |note|
          {
            id:                 note.id,
            content:            note.content,
            visibility:         note.visibility,
            category:           note.note_category&.name || "Uncategorised",
            owner:              note.telegram_user.display_name,
            created_at:         note.created_at.strftime("%-d %b %Y")
          }
        end

        ToolResult.ok(result.to_json)
      end
    end
  end
end
