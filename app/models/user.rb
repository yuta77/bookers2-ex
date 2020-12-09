class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise  :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable

  include JpPrefecture
  jp_prefecture :prefecture_code

  geocoded_by :address
  after_validation :geocode

  has_many :books, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_books, through: :favorites, source: :book
  has_many :book_comments, dependent: :destroy
  has_many :follower, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :followed, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followings, through: :follower, source: :followed
  has_many :followers, through: :followed, source: :follower

  has_many :chats, dependent: :destroy
  has_many :user_rooms, dependent: :destroy

  attachment :profile_image, destroy: false

  validates :name, length: { maximum: 20, minimum: 2 }
  validates :introduction, length: { maximum: 50 }

  def already_favorite?(book)
    favorites.exists?(book_id: book.id)
  end

  def follow(other_user)
    unless self == other_user
      follower.create(followed_id: other_user.id)
    end
  end

  def unfollow(other_user)
    follower.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    followings.include?(other_user)
  end

  def prefecture_name
    JpPrefecture::Prefecture.find(code: prefecture_code).try(:name)
  end

  def prefecture_name=(prefecture_name)
    self.prefecture_code = JpPrefecture::Prefecture.find(name: prefecture_name).code
  end

  def address
    "%s %s %s %s" % [prefecture_name, address_city, address_street, address_building]
  end
end
