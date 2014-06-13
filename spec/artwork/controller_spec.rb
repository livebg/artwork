require 'spec_helper'

module Artwork
  describe Controller do
    let(:application_controller) { Class.new }

    it 'adds an around_filter and declares view helpers when included' do
      expect(application_controller).to receive(:around_filter).with(:initialize_artwork_env)
      expect(application_controller).to receive(:helper).with(View)

      application_controller.send :include, Controller
    end
  end
end
