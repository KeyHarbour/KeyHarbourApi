require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../spec/dummy/config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  config.fixture_paths = [File.expand_path('fixtures', __dir__)]
  config.global_fixtures = :all
  config.include FactoryBot::Syntax::Methods

  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!
  config.infer_spec_type_from_file_location!
end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

# Dir[Rails.root.join("spec/factories/**/*.rb")].each { |file| require file }
FactoryBot.definition_file_paths = [
  File.expand_path("factories", __dir__)
]
Dir[File.expand_path('../support/**/*.rb', __FILE__)].sort.each do |f|
  # puts "Fichier chargé : #{f}" # AJOUTEZ AUSSI CECI
  require f
end