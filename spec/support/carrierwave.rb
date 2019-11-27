RSpec.configure do |config|
  config.after(:each, :carrierwave) do
    FileUtils.rm_rf(Dir[Rails.root.join('spec', 'fixtures', 'uploads')])
  end
end

Dir[Rails.root.join('app', 'uploaders', '*.rb')].each { |file| require file }

if defined?(CarrierWave)
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def upload_dir
        %w[spec fixtures uploads]
      end

      def cache_dir
        Rails.root.join(*upload_dir, 'tmp')
      end

      def store_dir
        Rails.root.join(*upload_dir, model.class.to_s.underscore.to_s, mounted_as.to_s, model.id)
      end
    end
  end
end
