require 'rubypress'

module Wprapper
  class Wordpress
    class << self
      def post_by_id(identifier)
        new.post(identifier)
      end

      def posts(filters)
        new.posts(filters)
      end

      def user(identifier)
        new.user(identifier)
      end

      def update_post(identifier, options={})
        new.update_post(identifier, options)
      end
    end

    def post(identifier)
      client.getPost(post_id: identifier)
    end

    def posts(filters)
      client.getPosts(filter: filters)
    end

    def user(identifier)
      default_fields = [ :user_id, :email, :display_name ]

      client.getUser(user_id: identifier, fields: default_fields)
    end

    def update_post(identifier, options)
      client.editPost(post_id: identifier, content: options)
    end

    def client
      @wp ||= Rubypress::Client.new({
        host:     Wprapper.configuration.hostname,
        username: Wprapper.configuration.username,
        password: Wprapper.configuration.password
      })
    end
  end
end