CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.storage = :file
  else
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: "", # Credentials are set with IAM profile but this is required for fog
      aws_secret_access_key: "",
      region: ENV['AWS_REGION'],
      use_iam_profile: true,
    }
    config.fog_directory = ENV['AWS_BUCKET']
    config.fog_public = false
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    config.storage = :fog
  end
end
