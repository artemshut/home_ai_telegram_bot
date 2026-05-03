module HomeAiTelegramBot
  module Telegram
    class WebhookHandler
      def initialize(update)
        @update = update
      end

      def call
        update_id = @update["update_id"]
        return if update_id.nil?
        return if TelegramMessage.exists?(update_id: update_id)

        message = @update["message"] || @update["edited_message"]
        return unless message

        from = message["from"]
        return unless from

        unless AuthGuard.new(from["id"]).allowed?
          Rails.logger.warn("Telegram update from unauthorized user #{from["id"]} rejected")
          return
        end

        telegram_user    = upsert_user(from)
        telegram_message = persist_message(update_id, message, telegram_user)
        ProcessTelegramUpdateJob.perform_later(@update.to_json, telegram_message.id)
      end

      private

      def upsert_user(from)
        TelegramUser.find_or_initialize_by(telegram_id: from["id"]).tap do |u|
          u.username   = from["username"]
          u.first_name = from["first_name"]
          u.last_name  = from["last_name"]
          u.save!
        end
      end

      def persist_message(update_id, message, telegram_user)
        TelegramMessage.create!(
          update_id:      update_id,
          telegram_user:  telegram_user,
          chat_id:        message.dig("chat", "id"),
          message_id:     message["message_id"],
          text:           message["text"],
          raw_update:     @update,
          direction:      "inbound"
        )
      end
    end
  end
end
