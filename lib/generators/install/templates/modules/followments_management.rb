module FollowmentsManagement
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :initialize
  end

  class TheUserIsAlreadyBeingFollowed < StandardError; end

  class TheUserIsNotBeingFollowed < StandardError; end
  
  module InstanceMethods

    # Gets the users that are not following the calling user.
    # A user's non_followers are all the users except the calling user and his followers.
    def non_followers
      User.where("id != ?", self.id) - self.followers
    end
    
    # Gets the users that are not being followed by the calling user.
    # A user's non_followed are all the users except the calling user and the users he is following.
    def non_followed
      User.where("id != ?", self.id) - self.followed
    end
    
    # Determines if a user is being followed by another user.
    def is_followed_by?(user)
      self.non_followers.include?(user)
    end
    
    # Determines if a user is following another user.
    def is_following_to?(user)
      !self.non_followed.include?(user)
    end
    
    # Determines if a user is blocked by another user.
    def is_blocked_by?(friend)
      friend.blocked_friends.include?(self)
    end
    
    # Makes the calling user to follow another user.
    def follow(user)
      #--
      # Only someone who is not still being followed can be followed.
      #++
      unless self.is_following_to?(user)
        self.followments.create(:followed_id => user.id)
      else
        raise TheUserIsAlreadyBeingFollowed, self.email + " is already following " + user.email + "."
      end
    end
    
    # Makes the calling user to unfollow another user.
    def unfollow(user)
      #--
      # Only someone who is being followed can be unfollowed.
      #++
      unless !self.is_following_to?(user)
        self.followments.find_by_followed_id(user.id).destroy
      else
        raise TheUserIsNotBeingFollowed, self.email + " was not following " + user.email + "."
      end
    end
  end
 
  module ClassMethods
    def initialize
      has_many :followments, :dependent => :destroy
      has_many :followings, :class_name => 'Followment', :foreign_key => 'followed_id'
      has_many :followed, :through => :followments, :source => :followed
      has_many :followers, :class_name => 'User', :through => :followings
    end
  end
end