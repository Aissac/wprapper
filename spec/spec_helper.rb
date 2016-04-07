require 'vcr'
require 'wprapper'
require 'support/stub_config'
require 'byebug'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include(StubConfig, vcr: true)
end

VCR.configure do |c|
  c.default_cassette_options = {
    record:                    :once,
    erb:                       true,
    serialize_with:            :json,
    preserve_exact_body_bytes: true
  }
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<WP_PASSWORD>') { ENV['WP_PASSWORD'] }
end
