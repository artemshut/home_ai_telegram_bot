module Ai
  module Tools
    class CreateNoteTool < BaseTool
      def self.tool_name = "create_note"
      def self.description = <<~DESC
        Save a note for the household. Provide the content and optionally visibility ('private' or 'public')
        and a category name. If visibility or category are omitted the bot will ask the user via inline buttons.
      DESC

      def self.schema
        {
          "type"       => "object",
          "properties" => {
            "content"       => { "type" => "string", "description" => "The note content" },
            "visibility"    => { "type" => "string", "enum" => %w[private public], "description" => "'private' (only you) or 'public' (all household members)" },
            "category_name" => { "type" => "string", "description" => "Category name for the note" }
          },
          "required" => [ "content" ]
        }
      end

      private

      def call(arguments, context)
        household = context.telegram_user&.household
        return ToolResult.err("No household found for this user.") unless household

        visibility    = arguments["visibility"]
        category_name = arguments["category_name"]

        if visibility.present? && category_name.present?
          create_confirmed_note(arguments, household, context)
        elsif visibility.present?
          create_pending_note_awaiting_category(arguments, household, context)
        else
          create_pending_note_awaiting_visibility(arguments, household, context)
        end
      end

      def create_confirmed_note(arguments, household, context)
        category = find_or_create_category(arguments["category_name"], household)
        note = household.notes.create!(
          content:       arguments["content"],
          visibility:    arguments["visibility"],
          status:        "confirmed",
          telegram_user: context.telegram_user,
          note_category: category
        )
        ToolResult.ok("Note saved (id: #{note.id}).")
      rescue ActiveRecord::RecordInvalid => e
        ToolResult.err("Could not save note: #{e.message}")
      end

      def create_pending_note_awaiting_category(arguments, household, context)
        note = household.notes.create!(
          content:       arguments["content"],
          visibility:    arguments["visibility"],
          status:        "pending",
          telegram_user: context.telegram_user
        )
        context.last_pending_note = note

        category_names = household.note_categories.order(:name).pluck(:name)
        ToolResult.ok(
          category_names.any? ? "pending_note_id:#{note.id}|needs:category|categories:#{category_names.join(",")}" \
                              : "pending_note_id:#{note.id}|needs:new_category"
        )
      rescue ActiveRecord::RecordInvalid => e
        ToolResult.err("Could not save note: #{e.message}")
      end

      def create_pending_note_awaiting_visibility(arguments, household, context)
        note = household.notes.create!(
          content:       arguments["content"],
          status:        "pending",
          telegram_user: context.telegram_user
        )
        context.last_pending_note = note
        ToolResult.ok("pending_note_id:#{note.id}|needs:visibility")
      rescue ActiveRecord::RecordInvalid => e
        ToolResult.err("Could not save note: #{e.message}")
      end

      def find_or_create_category(name, household)
        household.note_categories.find_or_create_by!(name: name.strip)
      rescue ActiveRecord::RecordInvalid
        household.note_categories.find_by!("LOWER(name) = ?", name.strip.downcase)
      end
    end
  end
end
