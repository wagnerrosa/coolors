ENV["RAILS_ENV"] = "test"

# dotenv loads .env before the environment boots, and DATABASE_URL takes
# precedence over the test: entry in database.yml — so without this the suite
# would run against the Neon database that serves the real site.
ENV.delete("DATABASE_URL")

require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
end
