require 'spec_helper'

describe User do
  before(:each) do
    @attr = { 
      :name => "Example User", 
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
    }
  end

  it "creates a new instance given valid attributes" do
    User.create!(@attr)
  end

  it "requires a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "requires an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "rejects names that are too long" do
    long_name = "a"*51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "accepts valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "rejects invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "rejects duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "rejects email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do

    it "requires a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "requires a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "rejects short passwords" do
      short = "a"*5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "rejects long passwords" do
      long = "a"*41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "has an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "sets the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "is true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "is false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "returns nil in email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "returns nil forn an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "returns the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end

    it "responds to admin" do
      @user.should respond_to(:admin)
    end

    it "is not an admin by default" do
      @user.should_not be_admin
    end

    it "is convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost associations" do
    before(:each) do
      @user = User.create(@attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "has a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "has microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "destroys associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        Micropost.find_by_id(micropost.id).should be_nil
      end
    end

    describe "status feed" do

      it "has a feed" do
        @user.should respond_to(:feed)
      end

      it "includes the user's micropsots" do
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end

      it "does not include a different user's microposts" do
        mp3 = Factory(:micropost,
                      :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end

      it "includes the microposts of dollowed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end
    end
  end

  describe "relationships" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

    it "has a relationships method" do
      @user.should respond_to(:relationships)
    end

    it "has a following method" do
      @user.should respond_to(:following)
    end

    it "has a following? method" do
      @user.should respond_to(:following?)
    end

    it "has a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "follows another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "includes the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "has an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end

    it "unfollows a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "has a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "has a followers method" do
      @user.should respond_to(:followers)
    end

    it "includes the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end

  end

end
