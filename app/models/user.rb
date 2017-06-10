# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  username               :string           default(""), not null
#  name                   :string
#  lastname               :string
#  bio                    :text
#  uid                    :string
#  provider               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  avatar_file_name       :string
#  avatar_content_type    :string
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  cover_file_name        :string
#  cover_content_type     :string
#  cover_file_size        :integer
#  cover_updated_at       :datetime
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers=>[:facebook]

  validates :username,presence: true,uniqueness: true,length: { in: 3..12 }
  validate :validate_username_regex

  has_many :posts
  has_many :friendships
  has_many :followers,class_name:"Friendship",foreign_key:"friend_id"

  has_many :friends_added, through: :friendships, source: :friend
  has_many :friends_who_added, through: :followers, source: :user


  has_attached_file :avatar,styles: {thumb: "100x100", medium:"300x300"},default_url:"/images/:style/profile-picture.jpg"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
  has_attached_file :cover,styles: {thumb: "400x300", medium:"800x600"},default_url:"/images/:style/missing_cover.png"
  validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/

  #Get id's list when users sent me a friendship request
  def get_friend_ids
    Friendship.active.where(user:self).pluck(:friend_id)
    #it's like select friend_id from friendships where user_id=myuserid
  end
  #Get id's list when I sent friendship request
  def get_user_ids
    Friendship.active.where(friend:self).pluck(:user_id)
  end
  def self.from_omniauth(auth)
    where(provider: auth[:provider], uid:auth[:uid]).first_or_create do |user|
      if auth[:info]
        user.email = auth[:info][:email]
        user.name  = auth[:info][:name]
      end
      user.password = Devise.friendly_token[0,20]
    end
  end

  def my_friend?(friend)
    Friendship.friends?(self,friend)
  end

  private
    def validate_username_regex
      unless username =~ /\A[a-zA-Z]*[a-zA-Z][a-zA-Z0-9_]*\z/
        errors.add(:username,"Username must start with a letter")
        errors.add(:username,"Username must not contain any special characters (except _)")
      end
    end
end
