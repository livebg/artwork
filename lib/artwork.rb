require 'artwork/version'
require 'artwork/configuration'
require 'artwork/model'
require 'artwork/view'
require 'artwork/controller'
require 'artwork/engine' if Rails.const_defined?(:Engine)

module Artwork
  extend Configuration
end
