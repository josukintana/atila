module FriendshipsManagement
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :initialize
  end

  class NoPendingFriendship < StandardError; end
  class NoRequestedFriendship < StandardError; end
  class UsersAreNotFriends < StandardError; end
  class UserIsBlocked < StandardError; end
  class UserIsNotBlocked < StandardError; end
  class UserCannotBeBlocked < StandardError; end
  class UserCannotBeRequested < StandardError; end
  
  module InstanceMethods

    # Gets the users that are friends of the calling user.
    # A user's non_followers are all the users except the calling user and his followers.
    def non_friends
      User.where("id != ?", self.id) - self.friends #My non_friends are all the users but me and my friends
    end
    
    # Determines if a user is already a friend of another user.
    def is_friend_of?(friend)
      self.friends.include?(friend)
    end
    
    # Determines if a user is blocked by another user.
    def is_blocked_by?(friend)
      friend.blocked_friends.include?(self)
    end
    
    # Determines if a user can request friendship to another user.
    # Friendships can be requested if users are not already friends and they have not got a pending friendship.
    def can_request_to?(friend)
      ((!self.is_friend_of?(friend)) && (!self.pending_friends.include?(friend)) && (!self.requested_friends.include?(friend)))
    end
    
    # Requests a user to be friend of the calling user.
    def request_friendship_to(friend)
      unless (!self.can_request_to?(friend))     
        #--
        # If the user is blocked by its potential friend, the friend will not be requested.
        #++
        unless self.is_blocked_by?(friend)
          friend.friendships.create(:friend_id => self.id, :status => Friendship::PENDING)  
        end
        
        unless friend.is_blocked_by?(self)
          self.friendships.create(:friend_id => friend.id, :status => Friendship::REQUESTED)
        else
          raise UserIsBlocked, self.email + " cannot request " + friend.email + "'s friendship because he/she has previously blocked that user."
        end
      else
        raise UserCannotBeRequested, self.email + " cannot request " + friend.email + "'s friendship."
      end
    end

    # Cancels a request of friendship from the calling user to another user.
    def cancel_request_to(friend)
      unless (!self.requested_friends.include?(friend))
        self.friendships.by_friend(friend).requested.first.destroy
        friend.friendships.by_friend(self).pending.first.destroy
      else
        raise NoRequestedFriendship, "There is no friendship requested by " + user.email + " to " + friend.email + "."
      end
    end
    
    # Accepts a friendship requested by another user to the calling user.
    def accept_friendship_of(friend)
      unless (!self.pending_friends.include?(friend))
        self.friendships.by_friend(friend).pending.first.accept #I'm the friend of my friend.
        friend.friendships.by_friend(self).requested.first.accept #My friend is a friend of mine.
      else
        raise NoPendingFriendship, "There is no pending friendship for " + user.email + " requested by " + friend.email + "."
      end
    end
    
    # Rejects a friendship requested by another user to the calling user.
    def reject_friendship_of(friend)
      unless (!self.pending_friends.include?(friend))
        self.friendships.by_friend(friend).pending.first.destroy #My friendship is destroyed.
        friend.friendships.by_friend(self).requested.first.reject #My friend's friendship is marked as rejected.
      else
        raise NoPendingFriendship, "There is no pending friendship for " + user.email + " requested by " + friend.email + "."
      end
    end
    
    # Cancels an existing friendship between the calling user and another user.
    def cancel_friendship_with(friend)
      unless (!self.is_friend_of?(friend))
        self.friendships.by_friend(friend).accepted.first.destroy #My friendship is destroyed.
        friend.friendships.by_friend(self).accepted.first.destroy #My friend's friendship is destroyed.
      else
        raise UsersAreNotFriends, self.email + " is not a friend of" + friend.email + "."
      end
    end
    
    # Blocks another user to avoid him to request a friendship to the calling user.
    def block_friend(friend)
      if ((self.can_request_to?(friend)) && (!self.blocked_friends.include?(friend)))
        self.friendships.create(:friend_id => friend.id, :status => Friendship::BLOCKED) #My friendship is blocked.
        self.email + " has correctly blocked " + friend.email + "."
      else
        raise UserCannotBeBlocked, "The user " + friend.email + " cannot be blocked by " + self.email + "." 
      end
    end
    
    # Unblock a previously blocked user.
    def unblock_friend(friend)
      unless (!self.blocked_friends.include?(friend))
        self.friendships.by_friend(friend).first.destroy #The blocked friendship is destroyed.
      else
        raise UserIsBlocked, "The user " + friend.email + " was not blocked by " + self.email + "." 
      end
    end
  end
 
  module ClassMethods
    # Sets up the necessary relationships between the User model and the Friendship model. 
    def initialize
      has_many :friendships, :dependent => :destroy
      has_many :friends, :through => :friendships, :conditions => "status = 'accepted'"
      has_many :requested_friends, :through => :friendships, :source => :friend, :conditions => "status = 'requested'", :order => :created_at
      has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "status = 'pending'", :order => :created_at
      has_many :blocked_friends, :through => :friendships, :source => :friend, :conditions => "status = 'blocked'", :order => :created_at
    end
  end
end