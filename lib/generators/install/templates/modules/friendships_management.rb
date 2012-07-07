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
    def non_friends
      User.where("id != ?", self.id) - self.friends #My non_friends are all the users but me and my friends
    end
    
    def is_friend_of?(friend)
      # Determines if a user is already a friend of mine
      self.friends.include?(friend)
    end
    
    def is_blocked_by?(friend)
      friend.blocked_friends.include?(self)
    end
    
    def can_request_to?(friend) #Friendships can be requested if users are not already friends and they have not got a pending friendship
      ((!self.is_friend_of?(friend)) && (!self.pending_friends.include?(friend)) && (!self.requested_friends.include?(friend)))
    end
    
    def request_friendship_to(friend)
      unless (!self.can_request_to?(friend))     #Only someone who is not still my friend can be requested
        unless self.is_blocked_by?(friend)  #If the user is blocked by its potential friend, the friend will
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
    
    def cancel_request_to(friend)
      unless (!self.requested_friends.include?(friend))
        self.friendships.by_friend(friend).requested.first.destroy #Cancel my friendship request.
        friend.friendships.by_friend(self).pending.first.destroy #Cancel my friend's pending request.
      else
        raise NoRequestedFriendship, "There is no friendship requested by " + user.email + " to " + friend.email + "."
      end
    end
    
    def accept_friendship_of(friend)
      unless (!self.pending_friends.include?(friend))
        self.friendships.by_friend(friend).pending.first.accept #I'm the friend of my friend.
        friend.friendships.by_friend(self).requested.first.accept #My friend is a friend of mine.
      else
        raise NoPendingFriendship, "There is no pending friendship for " + user.email + " requested by " + friend.email + "."
      end
    end
    
    def reject_friendship_of(friend)
      unless (!self.pending_friends.include?(friend))
        self.friendships.by_friend(friend).pending.first.destroy #My friendship is destroyed.
        friend.friendships.by_friend(self).requested.first.reject #My friend's friendship is marked as rejected.
      else
        raise NoPendingFriendship, "There is no pending friendship for " + user.email + " requested by " + friend.email + "."
      end
    end
    
    def cancel_friendship_with(friend)
      unless (!self.is_friend_of?(friend))
        self.friendships.by_friend(friend).accepted.first.destroy #My friendship is destroyed.
        friend.friendships.by_friend(self).accepted.first.destroy #My friend's friendship is destroyed.
      else
        raise UsersAreNotFriends, self.email + " is not a friend of" + friend.email + "."
      end
    end
    
    def block_friend(friend)
      if ((self.can_request_to?(friend)) && (!self.blocked_friends.include?(friend)))
        self.friendships.create(:friend_id => friend.id, :status => Friendship::BLOCKED) #My friendship is blocked.
        self.email + " has correctly blocked " + friend.email + "."
      else
        raise UserCannotBeBlocked, "The user " + friend.email + " cannot be blocked by " + self.email + "." 
      end
    end
    
    def unblock_friend(friend)
      unless (!self.blocked_friends.include?(friend))
        self.friendships.by_friend(friend).first.destroy #The blocked friendship is destroyed.
      else
        raise UserIsBlocked, "The user " + friend.email + " was not blocked by " + self.email + "." 
      end
    end
  end
 
  module ClassMethods
    def initialize
      has_many :friendships, :dependent => :destroy
      has_many :friends, :through => :friendships, :conditions => "status = 'accepted'"
      has_many :requested_friends, :through => :friendships, :source => :friend, :conditions => "status = 'requested'", :order => :created_at
      has_many :pending_friends, :through => :friendships, :source => :friend, :conditions => "status = 'pending'", :order => :created_at
      has_many :blocked_friends, :through => :friendships, :source => :friend, :conditions => "status = 'blocked'", :order => :created_at
    end
  end
end