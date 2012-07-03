require 'rails/generators'
require 'rails/generators/migration'

module Atila
	module Generators
		class InstallGenerator < Rails::Generators::Base
		  include Rails::Generators::Migration

		  source_root File.expand_path('../templates', __FILE__)
		  class_option :with_all, :type => :boolean, :default => false, :description => "Install all modules."
		  class_option :with_profiles, :type => :boolean, :default => false, :description => "Install profiles management module."
		  class_option :without_profiles, :type => :boolean, :default => false, :description => "Skip profiles management module."
		  class_option :with_friendships, :type => :boolean, :default => false, :description => "Install friendships management module."
		  class_option :without_friendships, :type => :boolean, :default => false, :description => "Skip friendships management module."
		  class_option :with_followments, :type => :boolean, :default => false, :description => "Install followments management module."
		  class_option :without_followments, :type => :boolean, :default => false, :description => "Skip followments management module."
		  class_option :with_groups, :type => :boolean, :default => false, :description => "Install groups management module."
		  class_option :without_groups, :type => :boolean, :default => false, :description => "Skip groups management module."

		  	# def set_application
		  	# 	environment "config.autoload_paths += %W(#{config.root}/lib)"
		  	# 	environment "config.autoload_paths += Dir['#{config.root}/lib/**/']"
		  	# end

		  	def install
		  		
		  		#Installation of profiles management module
		  		if options.with_profiles? || (options.with_all? && !options.without_profiles)
		        	#Copy models
		        	template "models/profile.rb", "app/models/profile.rb"

		        	#Copy modules
		        	template "modules/profiles_management.rb", "lib/atila/profiles_management.rb"

		        	#Generate migrations
		        	migration_template "migrations/create_profiles.rb", "db/migrate/create_profiles.rb"
		        end

		        #Installation of followment management module
		        if options.with_followment? || (options.with_all? && !options.without_followment)
		        	#Copy models
		        	template "models/followment.rb", "app/models/followment.rb"

		        	#Copy modules
		        	template "modules/followments_management.rb", "lib/atila/followments_management.rb"

		        	#Generate migrations
		        	migration_template "migrations/create_followments.rb", "db/migrate/create_followments.rb"
		        end

		        if options.with_friendships? || (options.with_all? && !options.without_friendships)
		        	#Copy models
		        	template "models/friendship.rb", "app/models/friendship.rb"

		        	#Copy modules
		        	template "modules/friendships_management.rb", "lib/atila/friendships_management.rb"

		        	#Generate migrations
		        	migration_template "migrations/create_friendships.rb", "db/migrate/create_friendships.rb"
		        end
		        
		        if options.with_groups? || (options.with_all? && !options.without_groups)
		        	#Copy models
			        template "models/group.rb", "app/models/group.rb"
			        template "models/membership.rb", "app/models/membership.rb"
			        template "models/ownership.rb", "app/models/ownership.rb"

			        #Copy modules
			        template "modules/groups_management.rb", "lib/atila/groups_management.rb"

			        #Generate migrations
			        migration_template "migrations/create_groups.rb", "db/migrate/create_groups.rb" 
		        	migration_template "migrations/create_memberships.rb", "db/migrate/create_memberships.rb"
		        	migration_template "migrations/create_ownerships.rb", "db/migrate/create_ownerships.rb"
		    	end

		    	readme "INSTALL"

		  	end

		  	def self.next_migration_number(path)
    			Time.now.utc.strftime("%Y%m%d%H%M%S%L") #We add milliseconds to timestamp to avoid multiple
    													#migrations with the same name
  			end
		end
	end
end