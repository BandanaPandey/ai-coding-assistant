class User < ApplicationRecord
  has_many :chat_sessions, dependent: :destroy

  before_create :generate_api_key

  private

  def generate_api_key
    self.api_key ||= SecureRandom.hex(32)
  end
end