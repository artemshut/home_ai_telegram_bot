module Telegram
  class AuthGuard
    def initialize(telegram_id)
      @telegram_id = telegram_id
    end

    def allowed?
      allowed_ids = Rails.application.credentials.dig(:telegram, :allowed_telegram_ids)
      return true if allowed_ids.blank?

      Array(allowed_ids).map(&:to_s).include?(@telegram_id.to_s)
    end
  end
end
