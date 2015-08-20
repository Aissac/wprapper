require 'active_support/core_ext/date_time/conversions'

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
          "12788", 
          "http://takeover.staging.wpengine.com/this-rare-footage-of-elvis-goin-country-will-make-you-fall-in-love-with-him-all-over-again/"
        ], 
        [
          "11048", 
          "http://takeover.staging.wpengine.com/this-little-girl-saw-a-marine-and-cried-i-was-speechless-when-i-found-out-why/"
        ], 
        [
          "12155", 
          "http://takeover.staging.wpengine.com/when-the-choir-started-singing-america-the-beautiful-i-couldnt-help-but-thank-god-for-our-country/"
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

  describe Wprapper::Post::Mapper do
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

  describe '.update_custom_fields' do
    let(:post) { Wprapper::Post.new({ identifier: '12345' }) }

    before do
      post.custom_fields = [ 
        { 'id' => 1,   'key' => 'a', 'value' => 'x' },
        { 'id' => 12,  'key' => 'b', 'value' => 'y' },
        { 'id' => 123, 'key' => 'c', 'value' => 'z' }
      ]
    end

    it 'should update only the custom fields specified' do
      custom_fields = { 'a' => 'test', 'z' => 'not existing' }
      expected_custom_fields_to_update = [
        { 'id' => 1, 'key' => 'a', 'value' => 'test' },
        { 'key' => 'z', 'value' => 'not existing' }
      ]

      expect_any_instance_of(Wprapper::Wordpress).to receive(:update_post).with(post.identifier, custom_fields: expected_custom_fields_to_update)

      post.update_custom_fields(custom_fields)
    end

    it 'should not update with fields with nil value' do
      custom_fields = { 'a' => nil, 'b' => 'new value' }

      expected_custom_fields_to_update = [
        { 'id' => 12, 'key' => 'b', 'value' => 'new value' }
      ]

      expect_any_instance_of(Wprapper::Wordpress).to receive(:update_post).with(post.identifier, custom_fields: expected_custom_fields_to_update)

      post.update_custom_fields(custom_fields)
    end
  end

  describe '.fetch_custom_field' do
    let(:post) { Wprapper::Post.new }

    before do
      post.custom_fields = [ 
        { 'id' => 1,   'key' => 'a', 'value' => 'x' },
        { 'id' => 12,  'key' => 'b', 'value' => 'y' },
        { 'id' => 123, 'key' => 'c', 'value' => 'z' }
      ]
    end

    it 'should fetch the custom field with an existing value' do
      result = post.fetch_custom_field('a')

      expect(result).to eql('x')
    end

    it 'should return the default value if the key docent exists' do
      result = post.fetch_custom_field('z')

      expect(result).to be_nil
    end

    it 'should return the specified default value when the key docent exists' do
      result = post.fetch_custom_field('z', 'default_value')

      expect(result).to eql('default_value')
    end
  end
end