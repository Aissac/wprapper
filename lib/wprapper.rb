require 'active_support'
require 'wprapper/version'
require 'wprapper/configuration'
require 'wprapper/base'
require 'wprapper/post'
require 'wprapper/author'
require 'wprapper/category'
require 'wprapper/wordpress'

module Wprapper
  class << self
  	def configure
  		yield(Configuration.current)
  	end
  end
end
