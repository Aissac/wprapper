require 'active_support/core_ext/object/blank'

module Wprapper
  class Post < Base
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
    property :custom_fields

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
          author_id:          r.fetch('post_author'),
          custom_fields:      fetch_custom_fields
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

      def fetch_custom_fields
        @custom_fields ||= @wp_post_hash.fetch('custom_fields', [])
      end

      def terms
        @wp_post_hash.fetch('terms', [])
      end

      def fetch_custom_field(key, default)
        field = fetch_custom_fields.find { |f|
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

        wordpress.posts(filters).map do |r|
          Post.new_from_wp(r)
        end
      end

      def find(post_id)
        wp_post = wordpress.post(post_id)

        Post.new_from_wp(wp_post)
      end
    end

    def published?
      status == 'publish'
    end

    def update_custom_fields(new_custom_fields)
      custom_fields_to_update = merge_custom_fields(new_custom_fields)
      
      Post.wordpress.update_post(identifier, custom_fields: custom_fields_to_update)
    end

    def attributes
      to_h.except(:categories, :author_id)
    end

    private
      def find_custom_field_by_key(key)
        custom_fields.find{|e| key == e['key'] }
      end

      def merge_custom_fields(new_custom_fields)
        new_custom_fields.map do |key, value|
          field = find_custom_field_by_key(key) || {}

          field['key']   = key
          field['value'] = value

          field
        end
      end
  end
end