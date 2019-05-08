class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def check
    render json: { status: 'OK' }, status: :ok
  end
end
