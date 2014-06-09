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

    def artwork_url(attachment_name, size, options = {})
      thumb_name = artwork_thumb_for(attachment_name, size)
      send(attachment_name).url(size, options)
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
