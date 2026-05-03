namespace :telegram do
  desc "Register webhook URL with Telegram (requires WEBHOOK_URL env var)"
  task set_webhook: :environment do
    url = ENV.fetch("WEBHOOK_URL") { abort "Set WEBHOOK_URL env var" }
    secret = Rails.application.credentials.dig(:telegram, :webhook_secret)
    token  = Rails.application.credentials.dig(:telegram, :bot_token)

    uri = URI("https://api.telegram.org/bot#{token}/setWebhook")
    body = { url: "#{url}/telegram/webhook" }
    body[:secret_token] = secret if secret.present?

    response = Net::HTTP.post(uri, body.to_json, "Content-Type" => "application/json")
    puts JSON.parse(response.body).inspect
  end

  desc "Delete the registered Telegram webhook"
  task delete_webhook: :environment do
    token = Rails.application.credentials.dig(:telegram, :bot_token)
    uri   = URI("https://api.telegram.org/bot#{token}/deleteWebhook")
    response = Net::HTTP.post(uri, "{}", "Content-Type" => "application/json")
    puts JSON.parse(response.body).inspect
  end
end
