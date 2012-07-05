module GroupsManagement
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :initialize
  end
  
  module InstanceMethods
    def group_exists?(name)
      !self.groups.find_by_name(name).nil?
    end
    
    def add_group(name)
      if !group_exists?(name)
        self.groups.create(:name => name)
      else
        raise GroupAlreadyExists, "The group '" + name + "' already exists."
      end
    end
    
    def remove_group(name)
      if group_exists?(name)
        self.groups.find_by_name(name).destroy
      else
        raise GroupNotFound, "The group '" + name + "' doesn't exist."
      end
    end
    
  end
 
  module ClassMethods
    def initialize
      has_many :memberships
      has_many :ownerships, :dependent => :destroy
      has_many :groups, :through => :ownerships
    end
  end
end