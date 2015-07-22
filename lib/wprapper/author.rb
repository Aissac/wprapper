module Wprapper
  class Author < Base
    property :display_name
    property :identifier
    property :email

    class << self
      def find(identifier)
        hash = wordpress.user(identifier)
        
        new({
          identifier:   hash.fetch('user_id'),
          display_name: hash.fetch('display_name'),
          email:        hash.fetch('email')
        })
      end
    end

    def attributes
      to_h
    end
  end
end