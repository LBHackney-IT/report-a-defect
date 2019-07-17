Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    'Lb0ng5QhbHpaV3f3lQSHPBIer3DSmaOR',
    ENV['AUTH0_CLIENT_SECRET'],
    ENV['AUTH0_DOMAIN'],
    callback_path: '/auth/oauth2/callback',
    authorize_params: {
      scope: 'openid profile',
    }
  )
end
