class ChatSession < ApplicationRecord
    has_many :messages, dependent: :destroy
    belongs_to :user
end
