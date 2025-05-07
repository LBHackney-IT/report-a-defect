class ApplicationController < ActionController::Base
  include Logout
  include PublicActivity::StoreController
  # protect_from_forgery with: :exception

  before_action :check_staging_auth, except: :check

  before_action do
    Rails.logger.info "=== REQUEST JSON: #{request.format.json?}"
    Rails.logger.info "=== REQUEST HOST: #{request.host}"
    Rails.logger.info "=== SESSION: #{request.session_options[:id]}"
    Rails.logger.info "=== CSRF token from session: #{session[:_csrf_token]}"
    Rails.logger.info "=== CSRF token from params: #{params[:authenticity_token]}"
  end
  

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
    @current_user ||= User.where(
      identifier: signed_in_user_id,
      name: signed_in_user_name
    ).first_or_initialize
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
