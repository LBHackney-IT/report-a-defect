class MessageVerifier
  def self.verifier
    ActiveSupport::MessageVerifier.new(
      Rails.application.secrets.secret_key_base,
      digest: 'SHA256'
    )
  end
end
