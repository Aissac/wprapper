require 'spec_helper'

describe Wprapper::Post do
  describe '.new_from_wp' do
    it 'builds a new object from a WP post' do
      published_at = Time.now.utc
      post_date_gmt = XMLRPC::DateTime.new(published_at.year,
                                           published_at.month,
                                           published_at.day,
                                           published_at.hour,
                                           published_at.min,
                                           published_at.sec
                                           )

      post = {
        'post_id'       => '1',
        'post_title'    => 'Foo Bar',
        'link'          => 'http://example.com',
        'post_content'  => 'text',
        'post_date_gmt' => post_date_gmt,
        'post_status'   => 'publish',
        'post_author'   => '1',
        'custom_fields' => [
          {
            'key'   => 'portrait_image',
            'value' => 'http://cat.jpg.to/'
          },
          {
            'key'   => 'title_position',
            'value' => 'bottom'
          }
        ],
        'terms' => [
          {
            'term_id'  => '123',
            'slug'     => 'entertainment',
            'name'     => 'Entertainment',
            'taxonomy' => 'category'
          }
        ]
      }

      wp_post = Wprapper::Post.new_from_wp(post)

      expect(wp_post).to be_an_instance_of(Wprapper::Post)

      fields = [
        wp_post.identifier,
        wp_post.title,
        wp_post.url,
        wp_post.content,
        wp_post.portrait_image_url,
        wp_post.title_position,
        wp_post.categories,
        wp_post.published_at.to_s(:db)
      ]

      values = [
        '1',
        'Foo Bar',
        'http://example.com',
        'text',
        'http://cat.jpg.to/',
        'bottom',
        [{ identifier: '123', name: 'Entertainment', slug: 'entertainment' }],
        published_at.to_s(:db)
      ]

      expect(fields).to eql(values)
    end
  end

  describe '.latest' do
    subject(:latest) { Wprapper::Post.latest(3) }

    it 'fetches the latest published posts', vcr: true do
      expected = [
        [
          '5482',
          'http://takeover.staging.wpengine.com/ronda-rousey-kicks-jimmy-fallons-ass/'
        ],
        [
          '5424',
          'http://takeover.staging.wpengine.com/when-he-found-out-his-son-was-the-school-bully-this-dads-response-is-epic/'
        ],
        [
          '5438',
          'http://takeover.staging.wpengine.com/forget-what-you-know-about-grilling-this-simple-trick-changes-everything/'
        ]
      ]

      actual = latest.map { |p|
        [
          p.identifier,
          p.url
        ]
      }

      expect(actual).to eql(expected)
    end
  end

  describe '.find' do
    it 'fetches the wordpress post', vcr: true  do
      wp_post = Wprapper::Post.find('5482')

      expect(wp_post.url).to eql('http://takeover.staging.wpengine.com/ronda-rousey-kicks-jimmy-fallons-ass/')
      expect(wp_post.identifier).to eql('5482')
      expect(wp_post.title).to eql('Things Got Real When UFC Fighter Ronda Rousey Showed Jimmy Fallon Why She\'s Called The "Arm Collector"')
    end
  end

  describe '.fetch_image_url' do
    it 'should fetch the image url successfuly from hash' do
      wp_post_hash = { 'post_thumbnail' => { 'link' => "www.image.com"  }}

      mapper = Wprapper::Post::Mapper.new(wp_post_hash)

      expect(mapper.fetch_image_url).to eql('www.image.com')
    end

    it 'should fetch the image url successfuly from array' do
      wp_post_hash = { 'post_thumbnail' => [ "www.image.com" ] }

      mapper = Wprapper::Post::Mapper.new(wp_post_hash)

      expect(mapper.fetch_image_url).to eql('www.image.com')
    end
  end
end