require 'simplecov'
require 'coveralls'

formatters = [SimpleCov::Formatter::HTMLFormatter, Coveralls::SimpleCov::Formatter]
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter::new(formatters)

SimpleCov.start do
  add_filter do |src|
    r = [
      src.filename =~ /lib/,
      src.filename =~ /models/,
      src.filename =~ /controllers/
    ].uniq
    r.count == 1 && r.first.nil?
  end

  add_filter "engine.rb"
  add_filter "spec.rb"
end

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'spec_helper'
require 'factory_girl_rails'
require 'shoulda-matchers'

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
