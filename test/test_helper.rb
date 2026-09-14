ENV["RAILS_ENV"] = "test"

require_relative "../config/environment"
require "rails/test_help"

# dotenv is development-only (see Gemfile), so DATABASE_URL is absent here and
# the suite uses the test: entry in database.yml. Guard it anyway: running
# against the Neon database that serves the live site would destroy real data.
if ActiveRecord::Base.connection_db_config.configuration_hash[:host].to_s.include?("neon.tech")
  abort "ABORTED: the test suite is pointed at Neon, not a local test database."
end

class ActiveSupport::TestCase
end
