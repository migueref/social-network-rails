require 'rails_helper'

RSpec.describe Friendship, type: :model do
  it{should belong_to :user}
  it{should belong_to :friend}

  it "should validate uniqueness of user with friend" do
    user = FactoryGirl.create(:user)
    friend = FactoryGirl.create(:user)

    FactoryGirl.create(:friendship,user: user, friend: friend)

    duplicated_friendship=FactoryGirl.build(:friendship,user: user, friend: friend)
    expect(duplicated_friendship.valid?).to be_falsy
  end
end
