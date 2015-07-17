require 'artwork/thumbnail'

module Artwork
  module Model
    def artwork_thumb_for(attachment_name, size, alternative_sizes = nil)
      size = determine_alternative_size_for(alternative_sizes) || size

      size, base_resolution = size.to_s.split('@')
      base_resolution ||= Artwork.base_resolution

      desired_thumb = Thumbnail.new(size)
      matching_thumb_name = nil

      ratio_for_current_resolution = base_resolution.to_f / Artwork.current_resolution.to_f

      if desired_thumb.compatible?
        desired_size = desired_thumb.width / ratio_for_current_resolution

        thumbs = attachment_styles_for(attachment_name).map { |thumb_name| Thumbnail.new(thumb_name) }

        thumbs = thumbs \
          .select(&:compatible?) \
          .reject(&:retina?) \
          .select { |thumb| desired_thumb.label.nil? or desired_thumb.label == thumb.label.to_s } \
          .select { |thumb| desired_thumb.aspect_ratio.nil? or desired_thumb.same_aspect_ratio_with?(thumb) } \
          .sort

        thumbs.each do |thumb|
          if desired_size <= thumb.width
            matching_thumb_name = thumb.name
            break
          end
        end

        # If we did not find any matching attachment definitions,
        # the desired size is probably larger than all of our thumb widths,
        # So pick the last (largest) one we have.
        return nil if thumbs.empty?
        matching_thumb_name ||= thumbs.last.name
      end

      matching_thumb_name ||= size.to_sym

      if Artwork.load_2x_images? and attachment_styles_for(attachment_name).include?(:"#{matching_thumb_name}_2x")
        matching_thumb_name = :"#{matching_thumb_name}_2x"
      end

      matching_thumb_name.to_sym
    end

    def artwork_url(attachment_name, size, options = {})
      thumb_name = artwork_thumb_for(attachment_name, size, options)
      send(attachment_name).url(thumb_name, options)
    end

    def attachment_styles_for(attachment_name)
      self.class.attachment_definitions[attachment_name.to_sym][:styles].keys
    end

    private

    def determine_alternative_size_for(alternative_sizes)
      return unless alternative_sizes

      new_size_definition = alternative_sizes \
        .select { |key, value| key.is_a? Numeric } \
        .sort_by { |max_resolution, size| max_resolution } \
        .find { |max_resolution, size| Artwork.actual_resolution <= max_resolution }

      new_size_definition.last if new_size_definition
    end
  end
end
