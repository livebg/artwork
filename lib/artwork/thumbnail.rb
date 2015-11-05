module Artwork
  class Thumbnail
    include Comparable

    STYLE_PATTERN = /\A
      (?<name>
        (?<width>\d+)x(?<height>\d+)?
        (?<label>(?!_2x)_\w*?)?
        (?<retina_flag>_2x)?
      )
    \z/ix.freeze

    class << self
      def from_style(style)
        data = {}

        if match = style.to_s.match(STYLE_PATTERN)
          data[:name]   = match[:name]
          data[:width]  = match[:width].to_i
          data[:height] = match[:height].to_i
          data[:label]  = match[:label] ? match[:label].gsub(/^_|_$/, '') : nil
          data[:retina] = !!match[:retina_flag]

          if data[:retina]
            data[:width]  *= 2
            data[:height] *= 2
          end
        else
          data[:name] = style.to_s
        end

        new(data)
      end

      def compatible?(style)
        style.to_s =~ STYLE_PATTERN ? true : false
      end
    end

    def initialize(name:, width: nil, height: nil, label: nil, retina: false)
      @name   = name
      @width  = width
      @height = height == 0 ? nil : height
      @label  = label
      @retina = retina

      @aspect_ratio = @width.to_f / @height if @height
    end

    attr_accessor :name, :width, :height, :label, :aspect_ratio
    attr_writer :retina

    def compatible?
      not width.nil?
    end

    def retina?
      @retina
    end

    def same_aspect_ratio_with?(other_thumb)
      return unless aspect_ratio and other_thumb.aspect_ratio

      (0.0..0.1).include? (aspect_ratio - other_thumb.aspect_ratio).abs
    end

    def <=>(other)
      if self.height.nil? and other.height.nil?
        (self.width || -1) <=> (other.width || -1)
      elsif !self.height.nil? and !other.height.nil?
        result = (self.width || -1) <=> (other.width || -1)

        if result == 0
          result = self.height <=> other.height
        end

        result
      elsif self.height.nil?
        -1
      else
        1
      end
    end

    def eq(other)
      self.name == other.name &&
        self.width   == other.width &&
        self.height  == other.height &&
        self.label   == other.label &&
        self.retina? == other.retina?
    end

    alias == eq

    def is_like?(other)
      self.label == other.label &&
        (self.aspect_ratio.nil? || self.same_aspect_ratio_with?(other))
    end
  end
end
