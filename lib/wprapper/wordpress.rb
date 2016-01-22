require 'rubypress'

module Wprapper
  class Wordpress
    def initialize(configuration)
      @configuration = configuration
    end

    def post(identifier)
      client.getPost(post_id: identifier)
    end

    def posts(filters)
      client.getPosts(filter: filters)
    end

    def user(identifier)
      default_fields = [:user_id, :email, :display_name]

      client.getUser(user_id: identifier, fields: default_fields)
    end

    def update_post(identifier, options)
      client.editPost(post_id: identifier, content: options)
    end

    def client
      @wp ||= Rubypress::Client.new(
        host:     @configuration.hostname,
        username: @configuration.username,
        password: @configuration.password
      )
    end
  end
end
