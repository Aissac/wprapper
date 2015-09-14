require 'active_support'
require 'rest_client'
require 'wprapper/version'
require 'wprapper/configuration'
require 'wprapper/base'
require 'wprapper/post'
require 'wprapper/author'
require 'wprapper/category'
require 'wprapper/wordpress'
require 'wprapper/wordpress_json_api'

module Wprapper
  class << self
  	def configure
  		yield(Configuration.current)
  	end
  end
end
