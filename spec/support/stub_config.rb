require "active_support"

module StubConfig
  extend ActiveSupport::Concern

  included do
    Wprapper::Configuration.current.hostname = "takeover.staging.wpengine.com"
    Wprapper::Configuration.current.username = "spdev"
    Wprapper::Configuration.current.password = "rQEUD5KAX4h0"
  end
end