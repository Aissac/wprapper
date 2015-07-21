module Wprapper
  class Category < Hashie::Dash
    property :identifier
    property :name
    property :slug

    class << self
      def new_from_wp(c)
        new({
          identifier: c['term_id'],
          name:       c['name'],
          slug:       c['slug']
        })
      end
    end

    def attributes
      to_h
    end
  end
end