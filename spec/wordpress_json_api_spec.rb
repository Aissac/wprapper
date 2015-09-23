describe Wprapper::WordpressJsonApi do
  let(:config) { Wprapper::Configuration.current }
  let(:api) { Wprapper::WordpressJsonApi.new(config) }
  
  describe '.auth_header' do
    it 'should create an authorization header' do
      config.username = "test"
      config.password = "test"

      expect(api.auth_header).to eql({
        'Authorization' => "Basic dGVzdDp0ZXN0\n"
      })
    end
  end

  describe '.mime_type_for' do
    it 'should extract the mime type from filename' do
      expect(api.mime_type_for("test.png")).to eql("image/png")
    end
  end

  describe '.media_headers' do
    it 'should create the headers for uploading a png file' do
      config.username = "test"
      config.password = "test"

      expected = {"Authorization"=>"Basic dGVzdDp0ZXN0\n", "Content-Type"=>"image/png", "Content-Disposition"=>"attachment; filename=test.png"}
      expect(api.media_headers("test.png")).to eql(expected)
    end
  end

  describe '.url_for' do
    it 'should build the relative url for media upload' do
      config.hostname = 'test'

      expect(api.url_for("/media")).to eql("#{config.hostname}/wp-json/media")
      expect(api.url_for("/media?post_id=1")).to eql("#{config.hostname}/wp-json/media?post_id=1")
    end
  end

  describe '.upload_media' do
    let(:image_url)  { "spec/fixtures/test.png" }
    let(:image_bytes) { File.read(image_url) }
    let(:image_filename) { File.basename(image_url) }

    it 'should upload successfuly the image successfuly to wordpress', vcr: true do
      wp_media = api.upload_media(image_filename, image_bytes)
      expect(wp_media['ID']).to eql(15411)
    end
  end
end