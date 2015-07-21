require 'hashie'

module Wprapper
  class Post < Hashie::Dash
    property :categories
    property :content
    property :identifier
    property :image_url
    property :portrait_image_url
    property :published_at
    property :title
    property :title_position
    property :url
    property :status
    property :author_id

    class Mapper
      def initialize(wp_post_hash)
        @wp_post_hash = wp_post_hash
      end

      def to_h
        r = @wp_post_hash

        {
          categories:         fetch_categories,
          content:            r.fetch('post_content'),
          identifier:         r.fetch('post_id'),
          image_url:          fetch_image_url,
          portrait_image_url: fetch_custom_field('portrait_image', nil),
          published_at:       r.fetch('post_date_gmt').to_time,
          title:              r.fetch('post_title'),
          title_position:     fetch_custom_field('title_position', nil),
          url:                r.fetch('link'),
          status:             r.fetch('post_status'),
          author_id:          r.fetch('post_author')
        }
      end

      def fetch_image_url
        post_thumbnail = @wp_post_hash.fetch('post_thumbnail', {})

        if post_thumbnail.is_a?(Hash)
          post_thumbnail.fetch('link', nil)
        else
          post_thumbnail.first
        end
      end

      def custom_fields
        @wp_post_hash.fetch('custom_fields', [])
      end

      def terms
        @wp_post_hash.fetch('terms', [])
      end

      def fetch_custom_field(key, default)
        field = custom_fields.find { |f|
          f.fetch('key') == key
        }

        if field.present?
          field.fetch('value')
        else
          default
        end
      end

      def fetch_categories
        terms.select{|t| t['taxonomy'] == 'category'}
             .map{|c| Category.new_from_wp(c)}
      end

      def fetch_term(taxonomy, default)
        term = terms.find { |t|
          t.fetch('taxonomy') == taxonomy
        }

        if term.present?
          term.fetch('name')
        else
          default
        end
      end
    end

    class << self
      def new_from_wp(r)
        new(Mapper.new(r).to_h)
      end

      def latest(number)
        filters = {
          number:      number,
          order:       'desc',
          orderby:     'post_date_gmt',
          post_status: 'publish',
          post_type:   'post'
        }

        Wordpress.posts(filters).map do |r|
          Post.new_from_wp(r)
        end
      end

      def find(post_id)
        wp_post = Wordpress.post_by_id(post_id)

        Post.new_from_wp(wp_post)
      end
    end

    def attributes
      to_h.except(:categories, :author_id)
    end
  end
end