require 'artwork/version'
require 'artwork/configuration'
require 'artwork/thumbnail'
require 'artwork/desired_thumbnail'
require 'artwork/model'
require 'artwork/view'
require 'artwork/controller'
require 'artwork/engine' if Object.const_defined?(:Rails) and Rails.const_defined?(:Engine)

module Artwork
  extend Configuration

  class << self
    def root_path
      File.dirname(__FILE__)
    end

    def desired_thumb_for(size, base_resolution = nil)
      if size.is_a? Numeric
        DesiredThumbnail.new(width: size, base_resolution: base_resolution)
      else
        thumb = DesiredThumbnail.from_style(size)

        thumb.base_resolution = base_resolution if base_resolution

        thumb
      end
    end

    def scale_in_current_resolution(size, base_resolution = nil)
      desired_thumb_for(size, base_resolution).width_in_current_resolution
    end

    def expected_width_for(size, base_resolution = nil)
      desired_thumb_for(size, base_resolution).expected_width
    end
  end
end
