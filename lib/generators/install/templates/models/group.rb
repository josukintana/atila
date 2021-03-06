class Group < ActiveRecord::Base
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name
  
  has_many :activities
  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :user
  has_one :ownership
  has_one :owner, :through => :ownership, :source => :user
  
  # Adds a user to a group.
  def add_member(user)
    if (!self.members.include?(user))
      self.members << user
    else
      raise GroupsManagement::UserIsAlreadyMember, "The user " + user.email + " is already a member of '" + self.name + "'."
    end
  end

  # Removes a user from a group.
  def remove_member(user)
    if (self.members.include?(user))
      self.memberships.find_by_user_id(user.id).destroy
    else
       raise GroupsManagement::UserIsNotMember, "The user " + user.email + " is not a member of the group '" + self.name + "'."
    end
    
  end
end
