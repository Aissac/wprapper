require_relative 'configuration'
require 'active_support/core_ext/class/attribute'
require 'hashie'

module Wprapper
	class Base < Hashie::Dash
    class_attribute :configuration

    self.configuration = Configuration.current

    class << self
      def wordpress
        Wordpress.new(configuration)
      end

      def wordpress_json_api
        WordpressJsonApi.new(configuration)
      end
    end
  end
end