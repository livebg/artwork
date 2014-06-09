module Artwork
  module Model
    ARTWORK_THUMBNAIL_NAME_PATTERN = /^[0-9]+x(\w+?)?(_2x)?$/i.freeze

    def artwork_thumb_for(attachment_name, size)
      size = size.to_s
      matching_thumb_name = nil

      if size =~ ARTWORK_THUMBNAIL_NAME_PATTERN
        desired_size = size.to_i / ratio_for_current_resolution

        available_attachments = attachment_styles_for(attachment_name)
          .grep(ARTWORK_THUMBNAIL_NAME_PATTERN)
          .sort_by { |name| name.to_s.to_i }

        available_attachments.each do |style_name|
          style_width = style_name.to_s.to_i

          if desired_size <= style_width
            matching_thumb_name = style_name
            break
          end
        end

        # If we did not find any matching attachment definitions,
        # the desired size is probably larger than all of our thumb widths,
        # So pick the last (largest) one we have.
        matching_thumb_name ||= available_attachments.last
      end

      matching_thumb_name ||= size.to_sym

      if Artwork.load_2x_images? and attachment_styles_for(attachment_name).include?(:"#{matching_thumb_name}_2x")
        matching_thumb_name = :"#{matching_thumb_name}_2x"
      end

      matching_thumb_name
    end

    def artwork_url(attachment_name = '', size = '', options = {})
      size = size.to_s

      # Fallback to poster_url or image_url if available and required size not like new schema (eg. 320x, 320x_2x)
      return poster_url(size) if respond_to?(:poster_url) && size !~ ARTWORK_THUMBNAIL_NAME_PATTERN

      thumb_name = artwork_thumb_for(attachment_name, size)

      raw_artwork_url(attachment_name, thumb_name, options)
    end

    def raw_artwork_url(attachment_name, size, options = {})
      path = artwork_path attachment_name, size, options

      # TODO: fix/remove
      ContentDistributionHelper.url options.reverse_merge(:self => self, :zone => 'updates', :path => "/#{path}")
    end

    def artwork_path(attachment_name, size, options = {})
      custom_attachment_path Paperclip::Attachment.new(attachment_name,''), size, options
    rescue ArgumentError
      custom_attachment_path Paperclip::Attachment.new(attachment_name,''), size
    end

    def attachment_styles_for(attachment_name)
      self.class.attachment_definitions[attachment_name.to_sym][:styles].keys
    end

    private

    def ratio_for_current_resolution
      Artwork.default_resolution.to_f / Artwork.current_resolution.to_f
    end
  end
end
