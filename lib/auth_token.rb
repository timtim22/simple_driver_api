class AuthToken
  def self.issue_token(payload)
    JWT.encode(payload, Rails.application.secrets.secret_key_base, 'HS256')
  end

  def self.valid?(token)
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: 'HS256' })
      true
    rescue JWT::DecodeError
      false
    end
  end
end
