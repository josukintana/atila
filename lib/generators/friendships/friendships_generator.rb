module Atila
	module Generators
		class FriendshipsGenerator < Rails::Generators::Base
		  include Rails::Generators::Migration
		  source_root File.expand_path('../templates', __FILE__)

		  	def copy_friendships_files
		        template "friendship.rb", "app/models/friendship.rb"
		        template "friends_management.rb", "lib/atila/friends_management.rb"
		  	end

		  	def self.next_migration_number(path)
    			Time.now.utc.strftime("%Y%m%d%H%M%S")
  			end

		  	def create_migration_file
    			migration_template 'create_friendships.rb', 'db/migrate/create_friendships.rb'
  			end
		end
	end
end