require 'fileutils'

class ArtworkAssetsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      has_assets = begin
        Rails.configuration.assets
      rescue
        nil
      end

      if has_assets
        puts <<-MESSAGE
          The version of Rails you're using (#{Rails.version}) supports
          the asset pipeline and the required assets will be automatically
          available for your app. You just need to require them in your
          manifest files. See how in the readme.
        MESSAGE
      else
        assets_root = File.expand_path('../../../lib/assets', __FILE__)
        FileUtils.cp_r Dir.glob("#{assets_root}/*"), Rails.root.join('public'), :verbose => true
        puts 'Done.'
      end
    end
  end
end
