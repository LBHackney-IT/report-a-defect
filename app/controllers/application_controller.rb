class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  protect_from_forgery with: :exception

  before_action :check_staging_auth, except: :check

  def check
    render json: { status: 'OK' }, status: :ok
  end

  def check_staging_auth
    return unless authenticate?

    authenticate_or_request_with_http_basic('Global') do |name, password|
      name == Figaro.env.http_user && password == Figaro.env.http_pass
    end
  end

  # rubocop:disable Rails/UnknownEnv
  def authenticate?
    Rails.env.staging? || (Figaro.env.http_user && Figaro.env.http_pass)
  end
  # rubocop:enable Rails/UnknownEnv

  def current_user
    User.find_or_create_by(identifier: 'dxw')
  end
end
