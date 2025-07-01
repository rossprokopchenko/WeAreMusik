namespace :wearemusik do
  desc "Safely initialize the primary database ONLY if it does NOT already exist"
  task initialize: :environment do
    # Connect to the primary DB
    config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: "primary").configuration_hash

    # Establish a temporary connection to postgres (or any template DB) to check for existence
    ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres'))
    exists = ActiveRecord::Base.connection.execute("SELECT 1 FROM pg_database WHERE datname='#{config[:database]}'").any?

    if exists
      puts "❌ Database '#{config[:database]}' already exists! Aborting initialization."
    else
      puts "✅ Database '#{config[:database]}' does not exist. Running full initialization..."

      puts "Creating primary database..."

      Rake::Task["db:create:primary"].invoke
      Rake::Task["db:create:primary"].reenable

      puts "✅ Finished creating primary database."

      puts "Running migrations on primary database..."

      Rake::Task["db:migrate:primary"].invoke
      Rake::Task["db:migrate:primary"].reenable

      puts "✅ Finished migrations on primary database."

      puts "Dumping schema of primary database..."

      Rake::Task["db:schema:dump:primary"].invoke
      Rake::Task["db:schema:dump:primary"].reenable

      puts "✅ Finished dumping schema of primary database."

      puts "✅ Primary database initialization complete!"
    end
  end
end
