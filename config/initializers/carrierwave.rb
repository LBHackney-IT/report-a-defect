CarrierWave.configure do |config|
  if Rails.env.development? || Rails.env.test?
    config.storage = :file
  else
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      region: ENV['AWS_REGION'],
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
    }
    config.fog_directory = ENV['AWS_BUCKET']
    config.fog_public = false
    config.fog_attributes = { 'Cache-Control' => 'max-age=315576000' }
    config.storage = :fog
  end
end
