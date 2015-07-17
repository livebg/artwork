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
end
