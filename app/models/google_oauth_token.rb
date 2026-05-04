class GoogleOauthToken < ApplicationRecord
  belongs_to :household

  def expired?
    expires_at.present? && expires_at <= Time.current
  end
end
