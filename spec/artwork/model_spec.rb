require 'spec_helper'

module Artwork
  describe Model do
    let(:model) { Class.new { include Artwork::Model } }
    let(:instance) { model.new }

    before :each do
      allow(model).to receive(:attachment_definitions).and_return({
        :image => {
          :styles => {
            :'320x'               => '320x>',
            :'320x_2x'            => '640x>',
            :'640x'               => '640x>',
            :'640x_2x'            => '1280x>',
            :'1280x'              => '1280x>',
            :'1280x_2x'           => '2560x>',
            :'320x_some_label'    => '320x>',
            :'320x_some_label_2x' => '640x>',
            :'320x500'            => '320x500>',
            :'320x500_2x'         => '640x1000>',
            :'320x500_crop'       => '320x500#',
            :'320x500_crop_2x'    => '640x1000#',
          },
        },
      })
    end

    describe '#attachment_styles_for' do
      it 'returns the list of available thumbnails' do
        expect(instance.attachment_styles_for(:image)).to match_array [
          :'320x',
          :'320x_2x',
          :'640x',
          :'640x_2x',
          :'1280x',
          :'1280x_2x',
          :'320x_some_label',
          :'320x_some_label_2x',
          :'320x500',
          :'320x500_2x',
          :'320x500_crop',
          :'320x500_crop_2x',
        ]
      end
    end

    describe '#artwork_url' do
      it 'returns the computed url of an attachment by delegating to artwork_thumb_for' do
        expect(instance).to receive(:artwork_thumb_for).with(:photo, :size).and_return(:computed_size)

        attachment = double
        expect(attachment).to receive(:url).with(:computed_size, 'options').and_return 'some/url'
        expect(instance).to receive(:photo).and_return(attachment)

        expect(instance.artwork_url(:photo, :size, 'options')).to eq 'some/url'
      end
    end
  end
end
