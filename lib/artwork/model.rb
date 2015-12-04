module Artwork
  module Model
    def artwork_url(attachment_name, size, options = {})
      thumb_name = attachment_style_for(attachment_name, size, options)

      return nil unless thumb_name

      send(attachment_name).url(thumb_name, options)
    end

    def attachment_styles_for(attachment_name)
      self.class.attachment_definitions[attachment_name.to_sym][:styles].keys
    end

    def attachment_style_for(attachment_name, size, alternative_sizes = nil)
      size = determine_alternative_size_for(alternative_sizes) || size

      thumb =
        if DesiredThumbnail.compatible?(size)
          artwork_thumb_for(attachment_name, size)
        else
          plain_thumb_for(attachment_name, size)
        end

      return nil unless thumb

      if thumb.respond_to?(:name)
        thumb.name.to_sym
      else
        thumb.to_sym
      end
    end

    def artwork_thumbs_for(attachment_name)
      attachment_styles_for(attachment_name).map { |style| Thumbnail.from_style(style) }
    end

    def artwork_thumb_for(attachment_name, size)
      desired_thumb = DesiredThumbnail.from_style(size)

      thumbs = artwork_thumbs_for(attachment_name)

      thumbs = thumbs.select(&:compatible?).select { |thumb| desired_thumb.is_like?(thumb) }.sort

      if Artwork.load_2x_images?
        retina_artwork_thumb_for(attachment_name, thumbs, desired_thumb)
      else
        normal_artwork_thumb_for(attachment_name, thumbs, desired_thumb)
      end
    end

    def plain_thumb_for(attachment_name, label)
      all_styles = attachment_styles_for(attachment_name)

      normal_thumb = label.to_sym
      retina_thumb = :"#{label}_2x"

      if Artwork.load_2x_images? and all_styles.include?(retina_thumb)
        retina_thumb
      elsif all_styles.include?(normal_thumb)
        normal_thumb
      end
    end

    def normal_artwork_thumb_for(attachment_name, thumbs, desired_thumb)
      usable_thumbs = thumbs.reject(&:retina?)

      thumb = usable_thumbs.find { |current| desired_thumb.expected_width <= current.width }

      thumb || usable_thumbs.max_by(&:width)
    end

    def retina_artwork_thumb_for(attachment_name, thumbs, desired_thumb)
      retina_thumbs = thumbs.select(&:retina?)

      thumb = retina_thumbs.find { |current| desired_thumb.expected_width <= current.width }

      thumb || normal_artwork_thumb_for(attachment_name, thumbs, desired_thumb) || retina_thumbs.max_by(&:width)
    end

    private

    def determine_alternative_size_for(alternative_sizes)
      return unless alternative_sizes

      new_size_definition = alternative_sizes \
        .select { |key, value| key.is_a? Numeric } \
        .sort_by { |max_resolution, size| max_resolution } \
        .find { |max_resolution, size| Artwork.current_resolution <= max_resolution }

      new_size_definition.last if new_size_definition
    end
  end
end
