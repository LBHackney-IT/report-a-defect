class ApplicationController < ActionController::Base
  include Logout
  include PublicActivity::StoreController
  protect_from_forgery with: :exception

  before_action :check_staging_auth, except: :check

  def check
    render json: { status: 'OK' }, status: :ok
  end

  def welcome; end

  def check_staging_auth
    return unless authenticate?

    authenticate_or_request_with_http_basic('Global') do |name, password|
      name == Figaro.env.http_user && password == Figaro.env.http_pass
    end
  end

  def authenticate?
    Figaro.env.http_user && Figaro.env.http_pass
  end

  helper_method :current_user
  def current_user
    return nil unless signed_in_user_id
    @current_user ||= User.find_or_create_by(
      identifier: signed_in_user_id,
      name: signed_in_user_name
    )
  end

  def sign_out
    reset_session
    redirect_to logout_url.to_s
  end

  def signed_in_user_id
    session[:userinfo]&.dig('uid') || nil
  end

  def signed_in_user_name
    session[:userinfo]&.dig('info', 'name') || nil
  end
end
