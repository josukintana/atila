module GroupsManagement
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :initialize
  end
  
  class GroupAlreadyExists < StandardError; end

  class GroupNotFound < StandardError; end

  module InstanceMethods

    # Determines if a group with the given name already exists.
    def group_exists?(name)
      !self.groups.find_by_name(name).nil?
    end
    
    # Creates a new group with the given where the calling user is the owner.
    def add_group(name)
      unless group_exists?(name)
        self.groups.create(:name => name)
      else
        raise GroupAlreadyExists, "The group '" + name + "' already exists."
      end
    end
    
    # Deletes a group with the given name where the calling user is its owner.
    def remove_group(name)
      unless !group_exists?(name)
        self.groups.find_by_name(name).destroy
      else
        raise GroupNotFound, "The group '" + name + "' does not exist."
      end
    end
    
  end
 
  module ClassMethods
    # Sets up the necessary relationships between the User model and the Membership and Ownership models. 
    def initialize
      has_many :memberships
      has_many :ownerships, :dependent => :destroy
      has_many :groups, :through => :ownerships
    end
  end
end