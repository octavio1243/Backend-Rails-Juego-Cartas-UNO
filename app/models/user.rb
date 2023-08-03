class User < ApplicationRecord
  has_secure_password
  has_one_attached :image
  has_many :my_cards
  has_and_belongs_to_many :teams
  has_many :games_users
  has_many :games, through: :games_users
  
  validates :name, :email, presence: true
  validates :email, uniqueness: true
  before_create :set_token

  def set_token
    self.token = SecureRandom.urlsafe_base64
  end

  def update_token
    set_token
    save
  end

  def authenticate(password)
    return false unless self.password_digest.present?
    BCrypt::Password.new(self.password_digest) == password
  end

end
