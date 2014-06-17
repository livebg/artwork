require 'artwork/thumbnail'

module Artwork
  module Model
    def artwork_thumb_for(attachment_name, size)
      desired_thumb = Thumbnail.new(size)
      matching_thumb_name = nil

      if desired_thumb.compatible?
        desired_size = desired_thumb.width / ratio_for_current_resolution

        thumbs = attachment_styles_for(attachment_name) \
          .map { |thumb_name| Thumbnail.new(thumb_name) } \
          .select(&:compatible?) \
          .reject(&:retina?) \
          .sort

        thumbs.each do |thumb|
          if desired_size <= thumb.width and thumb.label == desired_thumb.label
            matching_thumb_name = thumb.name
            break
          end
        end

        # If we did not find any matching attachment definitions,
        # the desired size is probably larger than all of our thumb widths,
        # So pick the last (largest) one we have.
        matching_thumb_name ||= thumbs.last.name
      end

      matching_thumb_name ||= size.to_sym

      if Artwork.load_2x_images? and attachment_styles_for(attachment_name).include?(:"#{matching_thumb_name}_2x")
        matching_thumb_name = :"#{matching_thumb_name}_2x"
      end

      matching_thumb_name.to_sym
    end

    def artwork_url(attachment_name, size, options = nil)
      thumb_name = artwork_thumb_for(attachment_name, size)
      send(attachment_name).url(thumb_name, options)
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
