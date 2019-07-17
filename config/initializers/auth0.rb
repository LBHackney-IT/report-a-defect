Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    'Lb0ng5QhbHpaV3f3lQSHPBIer3DSmaOR',
    ENV['AUTH0_CLIENT_SECRET'],
    'lbh-report-a-defect-development.eu.auth0.com',
    callback_path: '/auth/oauth2/callback',
    authorize_params: {
      scope: 'openid profile',
    }
  )
end
