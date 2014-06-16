module Artwork
  module Model
    THUMBNAIL_NAME_PATTERN = /^(\d+)x(\w*?)(_2x)?$/i.freeze

    class Thumb
      include Comparable

      attr :name
      attr :width
      attr :label

      def initialize(name)
        @name = name.to_s

        if @name =~ THUMBNAIL_NAME_PATTERN
          @width       = $1.to_i
          @label       = $2.to_s
          @retina_flag = $3
        end
      end

      def compatible?
        not width.nil?
      end

      def retina?
        @retina_flag == '_2x'
      end

      def <=>(other_thumb)
        width <=> other_thumb.width
      end
    end

    def artwork_thumb_for(attachment_name, size)
      size = size.to_s
      matching_thumb_name = nil

      if size =~ THUMBNAIL_NAME_PATTERN
        desired_size = size.to_i / ratio_for_current_resolution

        thumbs = attachment_styles_for(attachment_name) \
          .map { |thumb_name| Thumb.new(thumb_name) } \
          .select(&:compatible?) \
          .reject(&:retina?) \
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
        matching_thumb_name ||= thumbs.last.name
      end

      matching_thumb_name ||= size.to_sym

      if Artwork.load_2x_images? and attachment_styles_for(attachment_name).include?(:"#{matching_thumb_name}_2x")
        matching_thumb_name = :"#{matching_thumb_name}_2x"
      end

      matching_thumb_name.to_sym
    end

    def artwork_url(attachment_name, size, options = {})
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
