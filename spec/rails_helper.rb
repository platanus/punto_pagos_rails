ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'spec_helper'
require 'factory_girl_rails'
require 'shoulda-matchers'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.order = :random
  config.render_views
  config.include FactoryGirl::Syntax::Methods
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  FactoryGirl::SyntaxRunner.send(:include, RSpec::Mocks::ExampleMethods)
end
