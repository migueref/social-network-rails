class Friendship < ApplicationRecord
  include AASM
  belongs_to :user
  belongs_to :friend,class_name: "User"
  validates :user_id,uniqueness:{scope: :friend_id,message: "Friendship is already duplicated for this user"}

  def self.friends?(user,friend)
    return true if user==friend
    Friendship.where(user:user, friend:friend)
              .or(Friendship.where(user:friend, friend:user))
              .any?
  end

  def self.pending_for_user(user)
    Friendship.pending.where(friend: user)
  end
  def self.accepted_for_user(user)
    Friendship.active.where(friend: user)
  end
  def self.blocked_for_user(user)
    Friendship.blocked.where(friend: user)
  end

  aasm column: "status" do
    state :pending, initial: true
    state :active
    state :denied
    state :blocked

    event :accepted do
      transitions from: [:pending], to: [:active]
    end
    event :rejected do
      transitions from: [:pending,:active], to: [:denied]
    end
    event :blocked do
      transitions from: [:pending,:active], to: [:blocked]
    end
    event :restarted do
      transitions from: [:denied,:blocked], to: [:pending]
    end
  end
end
