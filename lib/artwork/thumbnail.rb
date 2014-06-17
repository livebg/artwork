module Artwork
  class Thumbnail
    include Comparable

    NAME_PATTERN = /^(\d+)x(\w*?)(_2x)?$/i.freeze

    attr :name
    attr :width
    attr :label

    def initialize(name)
      @name = name.to_s

      if match = @name.match(NAME_PATTERN)
        @width       = match[1].to_i
        @label       = match[2].to_s.gsub(/^_|_$/, '')
        @retina_flag = match[3]
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

    def eq(other)
      name    == other.name and \
      width   == other.width and \
      label   == other.label and \
      retina? == other.retina?
    end

    alias == eq

    def self.compatible?(name)
      name.to_s =~ NAME_PATTERN ? true : false
    end
  end
end
