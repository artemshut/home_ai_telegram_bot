module Google
  class OauthService
    SCOPE = "https://www.googleapis.com/auth/calendar".freeze

    def authorization_url(household_id:)
      client = oauth_client
      client.authorization_uri(
        scope:       SCOPE,
        state:       household_id.to_s,
        access_type: "offline",
        prompt:      "consent"
      ).to_s
    end

    def exchange_code(code:, state:)
      household = Household.find(state.to_i)
      client = oauth_client
      client.code = code
      client.fetch_access_token!

      token = GoogleOauthToken.find_or_initialize_by(household: household)
      token.update!(
        access_token:  client.access_token,
        refresh_token: client.refresh_token.presence || token.refresh_token,
        expires_at:    client.expires_at,
        token_type:    client.token_type.presence || "Bearer",
        scope:         SCOPE
      )
      token
    end

    def credentials_for(household)
      token = household.google_oauth_token
      return nil unless token&.refresh_token.present?

      ::Google::Auth::UserRefreshCredentials.new(
        client_id:     Rails.application.credentials.dig(:google, :client_id),
        client_secret: Rails.application.credentials.dig(:google, :client_secret),
        refresh_token: token.refresh_token,
        access_token:  token.access_token,
        expires_at:    token.expires_at,
        scope:         SCOPE
      )
    end

    private

    def oauth_client
      ::Signet::OAuth2::Client.new(
        client_id:              Rails.application.credentials.dig(:google, :client_id),
        client_secret:          Rails.application.credentials.dig(:google, :client_secret),
        redirect_uri:           Rails.application.credentials.dig(:google, :redirect_uri),
        token_credential_uri:   "https://oauth2.googleapis.com/token",
        authorization_uri:      "https://accounts.google.com/o/oauth2/auth"
      )
    end
  end
end
