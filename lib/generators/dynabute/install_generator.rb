require 'rails/generators'
require 'rails/generators/migration'

module Dynabute
  class InstallGenerator < Rails::Generators::Base
    include Rails::Generators::Migration
    source_root File.expand_path("../templates", __FILE__)
    desc "This generator installs migrations for Dynabute"
    # argument :stylesheets_type, :type => :string, :default => 'less', :banner => '*less or static'
    # class_option :'no-coffeescript', :type => :boolean, :default => false, :desc => 'Skips coffeescript replacement into app generators'

    def self.next_migration_number(path)
      next_migration_number = current_migration_number(path) + 1
      ActiveRecord::Migration.next_migration_number(next_migration_number)
    end

    def copy_migrations
      migration_template 'migration.rb', "db/migrate/create_dynabutes.rb"
    end
  end
end
