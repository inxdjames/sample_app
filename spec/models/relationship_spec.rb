require 'spec_helper'

describe Relationship do
  before(:each) do
    @follower = Factory(:user)
    @followed = Factory(:user, :email => Factory.next(:email))
    @relationship = @follower.relationships.build(:followed_id => @followed.id)
  end

  it "creates a new instance given valid attributes" do
    @relationship.save!
  end

  describe "follow methods" do
    before(:each) do
      @relationship.save
    end

    it "has a follower attribute" do
      @relationship.should respond_to(:follower)
    end

    it "has the right follower" do
      @relationship.follower.should == @follower
    end

    it "has a followed attrribute" do
      @relationship.should respond_to(:followed)
    end

    it "has the right followed user" do
      @relationship.followed.should == @followed
    end
  end

  describe "validations" do
    it "requires a follower_id" do
      @relationship.follower_id = nil
      @relationship.should_not be_valid
    end
    it "requires a followed_id" do
      @relationship.followed_id = nil
      @relationship.should_not be_valid
    end
  end

end
