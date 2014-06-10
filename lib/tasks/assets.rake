require 'file_utils'

namespace :artwork do
  namespace :assets do
    desc 'Copies the necessary static files in public/ for Rails < 3.1 apps'
    task :install => :environment do
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
        p [Rails.root.join('public')]
        # FileUtils.cp_r Artwork::Engine.root.join('lib/assets/*'), Rails.root.join('public')
      end
    end
  end
end
