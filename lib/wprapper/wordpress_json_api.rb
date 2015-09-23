#
# Wrapper over the json plugin for wordpress http://wp-api.org/.
# Requires the following plugins installed on wordpress host:
# - http://wp-api.org/
# - https://github.com/WP-API/Basic-Auth 
#
module Wprapper
  class WordpressJsonApi
    def initialize(configuration)
      @config = configuration
    end

    def auth_header
      base64_auth = Base64.encode64("#{@config.username}:#{@config.password}")
      
      {
        'Authorization' => "Basic #{base64_auth}"
      }
    end

    def mime_type_for(filename)
      MIME::Types.type_for(filename).first.to_s
    end

    def media_headers(filename)
      auth_header.merge({
        'Content-Type' => mime_type_for(filename),
        'Content-Disposition' => "attachment; filename=#{filename}"
      })
    end

    def url_for(path)
      File.join(@config.hostname, 'wp-json', path)
    end

    def upload_media(name, bytes)
      response = RestClient.post(url_for('media'), bytes, media_headers(name))
      JSON.parse(response)
    end
  end
end 