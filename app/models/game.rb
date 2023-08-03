require 'nanoid'

class Game < ApplicationRecord
  include CardEnum
  has_many :teams
  has_many :my_cards
  belongs_to :user
  has_many :games_users
  has_many :users, through: :games_users
  before_create :set_token
  
  def set_token
    self.token = Nanoid.generate(size: 6)
  end
end
