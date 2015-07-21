require "wprapper/version"
require "wprapper/configuration"
require "wprapper/post"

module Wprapper
  class << self

  	def configure
  		yield(configuration)
  	end

  	def configuration
  		@configuration ||= Configuration.new
  	end
  end
end
