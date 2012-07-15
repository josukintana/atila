module ProfilesManagement
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.send :initialize
  end
 
  module InstanceMethods
    # Creates a profile for the specified user.
    def create_profile
      Profile.create(:user_id => self.id)
    end
  end
 
  module ClassMethods
    # Sets up the necessary relationships between the User model and the Profile model. 
    def initialize
      has_one :profile
      
      after_create :create_profile
    end
  end
end