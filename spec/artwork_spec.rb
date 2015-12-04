require 'spec_helper'

describe Artwork do
  it 'responds to root_path' do
    expect(Artwork).to respond_to(:root_path)
  end

  it 'responds to configuration methods' do
    expect(Artwork).to respond_to(:configure_for)
    expect(Artwork).to respond_to(:reset_configuration)
    expect(Artwork).to respond_to(:base_resolution)
    expect(Artwork).to respond_to(:base_resolution=)
    expect(Artwork).to respond_to(:supported_resolutions_list)
    expect(Artwork).to respond_to(:supported_resolutions_list=)
    expect(Artwork).to respond_to(:load_2x_images?)
    expect(Artwork).to respond_to(:current_resolution)
  end

  describe 'proxy methods to DesiredThumbnail' do
    before :each do
      Artwork.base_resolution    = 1000
      Artwork.current_resolution = 1000
      Artwork.actual_resolution  = 1000
      Artwork.load_2x_images     = false
    end

    describe '::scale_in_current_resolution' do
      it 'will scale the passed width in the current resolution' do
        expect(Artwork.scale_in_current_resolution(320)).to eq(320)
        expect(Artwork.scale_in_current_resolution(320, 500)).to eq(640)
        expect(Artwork.scale_in_current_resolution('280x')).to eq(280)
        expect(Artwork.scale_in_current_resolution('280x_crop')).to eq(280)
        expect(Artwork.scale_in_current_resolution('280x500_crop')).to eq(280)
        expect(Artwork.scale_in_current_resolution('320x@500')).to eq(640)
        expect(Artwork.scale_in_current_resolution('320x@500', 250)).to eq(1280)

        Artwork.current_resolution = 2000
        expect(Artwork.scale_in_current_resolution(320)).to eq(640)
        expect(Artwork.scale_in_current_resolution(320, 500)).to eq(1280)
        expect(Artwork.scale_in_current_resolution('280x')).to eq(560)
        expect(Artwork.scale_in_current_resolution('280x_crop')).to eq(560)
        expect(Artwork.scale_in_current_resolution('280x500_crop')).to eq(560)
        expect(Artwork.scale_in_current_resolution('320x@500')).to eq(1280)
        expect(Artwork.scale_in_current_resolution('320x@500', 250)).to eq(2560)
      end

      it 'is not affected by the retina flag' do
        Artwork.load_2x_images     = true

        expect(Artwork.scale_in_current_resolution(320)).to eq(320)
        expect(Artwork.scale_in_current_resolution(320, 500)).to eq(640)
        expect(Artwork.scale_in_current_resolution('280x')).to eq(280)
        expect(Artwork.scale_in_current_resolution('280x_crop')).to eq(280)
        expect(Artwork.scale_in_current_resolution('280x500_crop')).to eq(280)
        expect(Artwork.scale_in_current_resolution('320x@500')).to eq(640)
        expect(Artwork.scale_in_current_resolution('320x@500', 250)).to eq(1280)

        Artwork.current_resolution = 2000
        expect(Artwork.scale_in_current_resolution(320)).to eq(640)
        expect(Artwork.scale_in_current_resolution(320, 500)).to eq(1280)
        expect(Artwork.scale_in_current_resolution('280x')).to eq(560)
        expect(Artwork.scale_in_current_resolution('280x_crop')).to eq(560)
        expect(Artwork.scale_in_current_resolution('280x500_crop')).to eq(560)
        expect(Artwork.scale_in_current_resolution('320x@500')).to eq(1280)
        expect(Artwork.scale_in_current_resolution('320x@500', 250)).to eq(2560)
      end
    end

    # The same as ::scale_in_current_resolution but it will double the width if retina
    describe '::expected_width_for' do
      it 'will return the expedted width in the current resolution' do
        expect(Artwork.expected_width_for(320)).to eq(320)
        expect(Artwork.expected_width_for(320, 500)).to eq(640)
        expect(Artwork.expected_width_for('280x')).to eq(280)
        expect(Artwork.expected_width_for('280x_crop')).to eq(280)
        expect(Artwork.expected_width_for('280x500_crop')).to eq(280)
        expect(Artwork.expected_width_for('320x@500')).to eq(640)
        expect(Artwork.expected_width_for('320x@500', 250)).to eq(1280)

        Artwork.current_resolution = 2000
        expect(Artwork.expected_width_for(320)).to eq(640)
        expect(Artwork.expected_width_for(320, 500)).to eq(1280)
        expect(Artwork.expected_width_for('280x')).to eq(560)
        expect(Artwork.expected_width_for('280x_crop')).to eq(560)
        expect(Artwork.expected_width_for('280x500_crop')).to eq(560)
        expect(Artwork.expected_width_for('320x@500')).to eq(1280)
        expect(Artwork.expected_width_for('320x@500', 250)).to eq(2560)
      end

      it 'will double the width if retina is expected' do
        Artwork.load_2x_images     = true

        expect(Artwork.expected_width_for(320)).to eq(640)
        expect(Artwork.expected_width_for(320, 500)).to eq(1280)
        expect(Artwork.expected_width_for('280x')).to eq(560)
        expect(Artwork.expected_width_for('280x_crop')).to eq(560)
        expect(Artwork.expected_width_for('280x500_crop')).to eq(560)
        expect(Artwork.expected_width_for('320x@500')).to eq(1280)
        expect(Artwork.expected_width_for('320x@500', 250)).to eq(2560)
      end
    end
  end
end
