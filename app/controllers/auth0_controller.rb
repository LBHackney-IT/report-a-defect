class Auth0Controller < ApplicationController
  def callback
    # This stores all the user information that came from Auth0
    # and the IdP
    session[:userinfo] = request.env['omniauth.auth']

    Rails.logger.info "Session after assignment: #{request.session.inspect}"

    # Redirect to the URL you want after successful auth
    redirect_to dashboard_url
  end

  def failure
    # show a failure page or redirect to an error page
    @error_msg = request.params['message']
  end
end
