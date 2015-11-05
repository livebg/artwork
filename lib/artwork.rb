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

    def scale_in_current_resolution(size, base_resolution = nil)
      if size.is_a? Numeric
        width = size
      else
        size, base = size.split('@')

        width = Thumbnail.from_style(size).width || 0
        base_resolution ||= base
      end

      base_resolution ||= Artwork.base_resolution

      resolution_ratio = base_resolution.to_f / Artwork.current_resolution.to_f

      width.to_f / resolution_ratio
    end
  end
end
