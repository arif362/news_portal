require "simplecov"
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"

  add_group "Controllers", "app/controllers"
  add_group "Models", "app/models"
  add_group "Jobs", "app/jobs"
  add_group "Mailers", "app/mailers"
  add_group "Services", "app/services"
  add_group "Helpers", "app/helpers"

  # Enforce minimum coverage once tests are in place
  # minimum_coverage 90
end

# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run only focused specs when tagged with :focus
  config.filter_run_when_matching :focus

  # Persist spec status for --only-failures support
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Disable monkey patching for cleaner spec isolation
  config.disable_monkey_patching!

  # Use doc formatter for single file runs
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  # Surface the 10 slowest specs
  config.profile_examples = 10

  # Random order to expose order dependencies
  config.order = :random
  Kernel.srand config.seed
end
