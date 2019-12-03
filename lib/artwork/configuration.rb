module Artwork
  module Configuration
    def supported_resolutions_list
      get(:supported_resolutions_list) or @@supported_resolutions_list or raise "Please set #{__method__}"
    end

    def supported_resolutions_list=(resolutions)
      list = resolutions.map(&:to_i).sort

      @@supported_resolutions_list ||= list
      set :supported_resolutions_list, list
    end

    def base_resolution
      get(:base_resolution) or @@base_resolution or raise "Please set #{__method__}"
    end
    
    def base_resolution=(resolution)
      @@base_resolution ||= resolution
      set :base_resolution, resolution
    end
    
    def blank_image
      get(:blank_image) or @@blank_image or raise "Please set #{__method__}"
    end

    def blank_image=(image)
      @@blank_image ||= image
      set :blank_image, image
    end

    def lazy_loading_class
      get(:lazy_loading_class) or @@lazy_loading_class or raise "Please set #{__method__}"
    end

    def lazy_loading_class=(image)
      @@lazy_loading_class ||= image
      set :lazy_loading_class, image
    end

    def load_2x_images?
      get(:load_2x_images) || false
    end

    def load_2x_images=(flag)
      set :load_2x_images, flag
    end

    def current_resolution
      get(:current_resolution) || base_resolution
    end

    def current_resolution=(resolution)
      set :current_resolution, resolution
    end

    def actual_resolution
      get(:actual_resolution) || base_resolution
    end

    def actual_resolution=(resolution)
      set :actual_resolution, resolution
    end

    def configure_for(request)
      Artwork.load_2x_images     = fetch_2x_images_flag_from(request)
      Artwork.current_resolution = current_resolution_from(request)
      Artwork.actual_resolution  = actual_resolution_from(request)
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

    def fetch_2x_images_flag_from(request)
      request.cookies['_retina'].to_i > 0
    end

    def current_resolution_from(request)
      browser_width = request.cookies['_width'].to_i

      return base_resolution if browser_width.zero?

      supported_resolutions_list.each do |resolution|
        return resolution if browser_width <= resolution
      end

      supported_resolutions_list.last
    end

    def actual_resolution_from(request)
      browser_width = request.cookies['_width'].to_i

      if browser_width > 0
        browser_width
      else
        base_resolution
      end
    end
  end
end
