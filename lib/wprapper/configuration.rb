module Wprapper
	class Configuration
    
    # The wordpress hostname 
    attr_accessor :hostname

    # The credentials for the wordpress api
    attr_accessor :username, :password

    class << self
      def current
        @config ||= new
      end
    end
	end
end