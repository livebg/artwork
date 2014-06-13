require 'spec_helper'

module Artwork
  describe Configuration do
    let(:config) { Class.new { extend Configuration } }

    before :each do
      thread_variables = {}
      allow(Thread).to receive(:current) { thread_variables }
    end

    [:default_resolution, :supported_resolutions_list].each do |option_name|
      describe "##{option_name}" do
        it 'raises an error if not set' do
          expect { config.send(option_name) }.to raise_error
        end

        it 'uses Thread.current to store values' do
          expect(Thread).to receive(:current).and_return(option_name => 'value')
          expect(config.send(option_name)).to eq 'value'
        end
      end
    end

    describe '#supported_resolutions_list=' do
      it 'converts the resolutions to integers' do
        config.supported_resolutions_list = ['123', '456']
        expect(config.supported_resolutions_list).to eq [123, 456]
      end
    end

    describe '#current_resolution' do
      it 'falls back to default_resolution' do
        expect(config).to receive(:default_resolution).and_return('default')
        expect(config.current_resolution).to eq 'default'
      end
    end

    describe '#current_resolution=' do
      it 'allows arbitrary resolutions if called directly' do
        config.current_resolution = 12345
        expect(config.current_resolution).to eq 12345
      end
    end

    describe '#reset_configuration' do
      it 'resets the current_resolution' do
        config.current_resolution = 'current'
        expect(config.current_resolution).to eq 'current'

        config.reset_configuration

        expect(config).to receive(:default_resolution).and_return('default')
        expect(config.current_resolution).to eq 'default'
      end

      it 'resets the retina flag' do
        config.load_2x_images = 'retina_flag'
        expect(config.load_2x_images?).to eq 'retina_flag'

        config.reset_configuration

        expect(config.load_2x_images?).to eq false
      end
    end

    describe '#configure_for' do
      def make_request(cookies_hash = {})
        double :cookies => cookies_hash
      end

      it 'sets current_resolution and load_2x_images from request cookies' do
        config.supported_resolutions_list = [1000, 2000, 3000]
        config.configure_for make_request('_retina' => '1', '_width' => '2000')

        expect(config.current_resolution).to eq 2000
        expect(config.load_2x_images?).to eq true
      end

      it 'sets the load_2x_images flag from the _retina cookie' do
        config.supported_resolutions_list = [1000, 2000, 3000]
        config.default_resolution = 1000

        config.configure_for make_request('_retina' => '0')
        expect(config.load_2x_images?).to eq false

        config.configure_for make_request('_retina' => '1')
        expect(config.load_2x_images?).to eq true
      end

      it 'picks only from the supported resolutions list' do
        config.supported_resolutions_list = [1000, 2000, 3000]

        config.configure_for make_request('_width' => '1234')
        expect(config.current_resolution).to eq 2000

        config.configure_for make_request('_width' => '234')
        expect(config.current_resolution).to eq 1000

        config.configure_for make_request('_width' => '10234')
        expect(config.current_resolution).to eq 3000
      end

      it 'falls back to default_resolution if no _width cookie' do
        config.supported_resolutions_list = []
        config.default_resolution = 5000

        config.configure_for make_request

        expect(config.current_resolution).to eq 5000
      end
    end
  end
end
