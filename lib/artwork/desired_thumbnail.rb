module Artwork
  class DesiredThumbnail < Thumbnail
    class << self
      def from_style(style)
        normal_style, base_resolution = style.to_s.split('@')

        data = {}

        if match = normal_style.match(Thumbnail::STYLE_PATTERN) and match[:retina_flag].nil?
          data[:name]   = match[:name]
          data[:width]  = match[:width].to_i
          data[:height] = match[:height].to_i
          data[:label]  = match[:label] ? match[:label].gsub(/^_|_$/, '') : nil
        else
          data[:name] = normal_style.to_s
        end

        data[:base_resolution] = base_resolution.to_i if base_resolution

        new(data)
      end

      def compatible?(style)
        from_style(style).compatible?
      end
    end

    def initialize(data = {})
      data = data.dup

      @base_resolution = data.delete(:base_resolution)

      data[:name] = "#{data[:width]}x" if data[:name].nil? and data[:width]

      super(data)
    end

    def width=(value)
      reset_cached_widths
      super
    end

    def base_resolution
      @base_resolution ||= Artwork.base_resolution
    end

    def base_resolution=(value)
      reset_cached_widths
      @base_resolution = value
    end

    def retina?
      Artwork.load_2x_images?
    end

    def width_in_current_resolution
      return @width_in_current_resolution if @width_in_current_resolution

      resolution_ratio = base_resolution.to_f / Artwork.current_resolution.to_f

      @width_in_current_resolution = width.to_f / resolution_ratio
    end

    def expected_width
      return @expected_width if @expected_width

      result = width_in_current_resolution

      @expected_width = retina? ? result * 2 : result
    end

    private

    def reset_cached_widths
      @expected_width = nil
      @width_in_current_resolution = nil
    end
  end
end
