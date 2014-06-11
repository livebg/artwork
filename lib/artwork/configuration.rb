module Artwork
  module Configuration
    def supported_resolutions_list
      get_required :supported_resolutions_list
    end

    def supported_resolutions_list=(resolutions)
      set :supported_resolutions_list, resolutions.map(&:to_i).sort
    end

    def default_resolution
      get_required :default_resolution
    end

    def default_resolution=(resolution)
      set :default_resolution, resolution
    end

    def load_2x_images?
      get(:load_2x_images) || false
    end

    def load_2x_images=(flag)
      set :load_2x_images, flag
    end

    def current_resolution
      get(:current_resolution) || default_resolution
    end

    def current_resolution=(resolution)
      set :current_resolution, resolution
    end

    def configure_for(request)
      Artwork.load_2x_images     = fetch_2x_images_flag_from(request)
      Artwork.current_resolution = current_resolution_from(request)
    end

    def reset_configuration
      set :current_resolution, nil
      set :load_2x_images, nil
    end

    private

    def set(setting, value)
      Thread.current[setting] = value
    end

    def get(setting)
      Thread.current[setting]
    end

    def get_required(setting)
      get(setting) or raise "Please set #{name}.#{setting}"
    end

    def fetch_2x_images_flag_from(request)
      request.cookies['_retina'].to_i > 0
    end

    def current_resolution_from(request)
      browser_width = request.cookies['_width'].to_i

      return default_resolution if browser_width.zero?

      supported_resolutions_list.each do |resolution|
        return resolution if browser_width <= resolution
      end

      supported_resolutions_list.last
    end
  end
end
