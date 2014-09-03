module Artwork
  class Thumbnail
    include Comparable

    NAME_PATTERN = /^(\d+)x(\d+)?((?!_2x)_\w+?)?(_2x)?$/i.freeze

    attr :name
    attr :width
    attr :height
    attr :label

    def initialize(name)
      @name = name.to_s

      if match = @name.match(NAME_PATTERN)
        @width       = match[1].to_i
        @height      = match[2].to_i
        @label       = match[3].to_s.gsub(/^_|_$/, '')
        @retina_flag = match[4]
      end

      @height = nil if @height == 0
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

    def eq(other)
      name    == other.name and \
      width   == other.width and \
      height  == other.height and \
      label   == other.label and \
      retina? == other.retina?
    end

    alias == eq

    def self.compatible?(name)
      name.to_s =~ NAME_PATTERN ? true : false
    end
  end
end