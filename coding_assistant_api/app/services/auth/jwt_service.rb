require "jwt"

module Auth
  class JwtService
    SECRET = Rails.application.secret_key_base
    ALGORITHM = "HS256"

    def self.encode(payload)
      payload[:exp] = 24.hours.from_now.to_i
      JWT.encode(payload, SECRET, ALGORITHM)
    end

    def self.decode(token)
      decoded = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM })[0]
      HashWithIndifferentAccess.new(decoded)
    end
  end
end