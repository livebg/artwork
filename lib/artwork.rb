require 'artwork/version'
require 'artwork/configuration'
require 'artwork/model'
require 'artwork/view'
require 'artwork/controller'
require 'artwork/engine' if Rails.const_defined?(:Engine)

module Artwork
  extend Configuration

  def self.root_path
    File.dirname(__FILE__)
  end
end
