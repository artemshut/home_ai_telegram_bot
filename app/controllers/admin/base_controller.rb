class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_admin

  private

  def authenticate_admin
    authenticate_or_request_with_http_basic("Admin") do |name, password|
      expected_name     = Rails.application.credentials.dig(:admin, :username) || "admin"
      expected_password = Rails.application.credentials.dig(:admin, :password) || "secret"
      ActiveSupport::SecurityUtils.secure_compare(name, expected_name) &&
        ActiveSupport::SecurityUtils.secure_compare(password, expected_password)
    end
  end
end
