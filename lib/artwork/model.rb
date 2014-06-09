module Artwork
  module Model
    def artwork_url(attachment_name = '', size = '', options = {})
      size = size.to_s

      # Fallback to poster_url or image_url if available and required size not like new schema (eg. 320x, 320x_2x)
      return poster_url(size) if respond_to?(:poster_url) && size !~ /^[0-9]*x(_2x)?$/i

      wanted_size = size.to_i / ratio_to_current_resolution
      styles = ARTWORK_STYLES.keys.map { |e| e.to_s.to_i }.sort
      styles.each_with_index do |e, i|
        if e < wanted_size && wanted_size < styles[i + 1]
          size = "#{styles[i + 1]}x"
        end
      end

      raw_artwork_url attachment_name, size, options
    end

    def raw_artwork_url(attachment_name, size, options = {})
      path = artwork_path attachment_name, size, options

      if options[:no_retina_compatibility].nil? and Artwork.load_2x_images?
        path = path.sub /\.jpg$/, '_2x.jpg'
      end

      # TODO: fix/remove
      ContentDistributionHelper.url options.reverse_merge(:self => self, :zone => 'updates', :path => "/#{path}")
    end

    def artwork_path(attachment_name, size, options = {})
      custom_attachment_path Paperclip::Attachment.new(attachment_name,''), size, options
    rescue ArgumentError
      custom_attachment_path Paperclip::Attachment.new(attachment_name,''), size
    end

    private

    def ratio_to_current_resolution
      Artwork.default_resolution.to_f / Artwork.current_resolution.to_f
    end
  end
end
