# Load necessary libraries
require "action_controller/railtie"
require "rspec/rails"
require "spec_helper"
require "phlex-rails"
require "view_component"

# Configure a minimal application for ActionController
class TestApplication < Rails::Application
  config.eager_load = false
  config.secret_key_base = "test"
  # Required to prevent ActionDispatch warnings
  config.hosts << "www.example.com"
  # Don't log to test output
  config.logger = Logger.new(File::NULL)
end

# Initialize the application
TestApplication.initialize!

RSpec.configure do |config|
  # Enable testing of controllers
  config.infer_spec_type_from_file_location!
end
