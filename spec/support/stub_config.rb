require 'dotenv'

Dotenv.load

module StubConfig
  extend ActiveSupport::Concern

  included do
    Wprapper.configure do |config|
      config.hostname = ENV['WP_HOSTNAME']
      config.username = ENV['WP_USERNAME']
      config.password = ENV['WP_PASSWORD']
    end
  end
end