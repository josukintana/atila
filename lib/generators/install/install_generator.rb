require 'rails/generators'
require 'rails/generators/migration'

module Atila
	module Generators
		class InstallGenerator < Rails::Generators::Base
		  include Rails::Generators::Migration
		  source_root File.expand_path('../templates', __FILE__)
		  class_option :with_friendships, :type => :boolean, :default => false, :description => "Install friendships management module."

		  	# def set_application
		  	# 	environment "config.autoload_paths += %W(#{config.root}/lib)"
		  	# 	environment "config.autoload_paths += Dir['#{config.root}/lib/**/']"
		  	# end

		  	def install
		  		#Copy models
		        template "models/friendship.rb", "app/models/friendship.rb" if options.with_friendships?

		        #Copy modules
		        template "modules/friendships_management.rb", "lib/atila/friendships_management.rb" if options.with_friendships?

		        #Generate migrations
		        migration_template 'migrations/create_friendships.rb', 'db/migrate/create_friendships.rb' if options.with_friendships?
		  	end

		  	def self.next_migration_number(path)
    			Time.now.utc.strftime("%Y%m%d%H%M%S")
  			end
		end
	end
end