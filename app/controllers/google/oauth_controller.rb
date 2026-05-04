module Google
  class OauthController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :callback

    def start
      household = Household.find(params[:household_id])
      url = Google::OauthService.new.authorization_url(household_id: household.id)
      redirect_to url, allow_other_host: true
    rescue ActiveRecord::RecordNotFound
      render plain: "Household not found.", status: :not_found
    end

    def callback
      code = params[:code]

      if code.blank?
        render plain: "Authorization failed: no code received.", status: :bad_request
        return
      end

      Google::OauthService.new.exchange_code(code: code, state: params[:state])
      render plain: "Google Calendar connected successfully! You can return to Telegram."
    rescue => e
      render plain: "Error: #{e.message}", status: :unprocessable_entity
    end
  end
end
