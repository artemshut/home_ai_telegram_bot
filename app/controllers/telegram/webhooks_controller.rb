module Telegram
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      return head :forbidden unless valid_secret_token?

      update = parse_update
      return head :ok unless update.is_a?(Hash)

      Telegram::WebhookHandler.new(update).call
      head :ok
    end

    private

    def valid_secret_token?
      expected = Rails.application.credentials.dig(:telegram, :webhook_secret)
      return true if expected.blank?

      received = request.headers["X-Telegram-Bot-Api-Secret-Token"]
      ActiveSupport::SecurityUtils.secure_compare(received.to_s, expected.to_s)
    end

    def parse_update
      JSON.parse(request.raw_post)
    rescue JSON::ParserError
      {}
    end
  end
end
