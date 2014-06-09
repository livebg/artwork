module Artwork
  module Controller
    def self.included(controller)
      controller.class_eval do
        around_filter :initialize_artwork_env
        helper View
      end
    end

    private

    def initialize_artwork_env
      Artwork.configure_for request
    ensure
      Artwork.reset_configuration
    end
  end
end
