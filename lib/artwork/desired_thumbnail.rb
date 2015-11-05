module Artwork
  class DesiredThumbnail < Thumbnail
    class << self
      def from_style(style)
        normal_style, base_resolution = style.to_s.split('@')

        thumb = super(normal_style)
        thumb.base_resolution = base_resolution

        thumb
      end

      def compatible?(style)
        from_style(style).compatible?
      end
    end

    def initialize(data = {})
      super(data)

      @base_resolution = data[:base_resolution]
    end

    attr_writer :base_resolution

    def base_resolution
      @base_resolution ||= Artwork.base_resolution
    end

    def expected_width
      result = Artwork.scale_in_current_resolution(width, base_resolution)

      if Artwork.load_2x_images?
        result * 2
      else
        result
      end
    end
  end
end
