module ModelSpec
  IMAGE_STYLES = {
    :'320x'               => '320x>',
    :'320x_2x'            => '640x>',
    :'640x_2x'            => '1280x>',
    :'640x'               => '640x>',
    :'1280x'              => '1280x>',
    :'1280x_2x'           => '2560x>',
    :'2000x'              => '2000x>',
    :'1500x_2x'           => '3000x>',
    :'320x_some_label'    => '320x>',
    :'320x_some_label_2x' => '640x>',
    :'320x500'            => '320x500>',
    :'320x500_2x'         => '640x1000>',
    :'320x500_crop'       => '320x500#',
    :'320x500_crop_2x'    => '640x1000#',
    :'400x500'            => '400x500>',
    :'400x500_2x'         => '800x1000>',
    :'320x_'              => '320x>',
    :unsupported          => '100x100>'
  }
end

#
# To use this example you have to provide
# let (:model) { ... }
# let (:instance) { ... }
# let (:attachment_name) { ... }
#
# also the attachment class should have an url method that receives (style, options)
# and should return "/#{attachment_name}-#{style}.jpg"
#
RSpec.shared_examples 'an artwork model' do
  describe '#attachment_styles_for' do
    it 'returns the list of available thumbnails' do
      expect(instance.attachment_styles_for(attachment_name)).to match_array [
        :'320x',
        :'320x_2x',
        :'640x_2x',
        :'640x',
        :'1280x',
        :'1280x_2x',
        :'2000x',
        :'1500x_2x',
        :'320x_some_label',
        :'320x_some_label_2x',
        :'320x500',
        :'320x500_2x',
        :'320x500_crop',
        :'320x500_crop_2x',
        :'400x500',
        :'400x500_2x',
        :'320x_',
        :unsupported,
      ]
    end
  end

  describe '#artwork_url' do
    describe 'behaviour' do
      it 'returns the computed url of an attachment by delegating to attachment_style_for' do
        expect(instance).to receive(:attachment_style_for).with(:photo, :size, 'options').and_return(:computed_size)

        attachment = double
        expect(attachment).to receive(:url).with(:computed_size, 'options').and_return 'some/url'
        expect(instance).to receive(:photo).and_return(attachment)

        expect(instance.artwork_url(:photo, :size, 'options')).to eq 'some/url'
      end

      it 'works with two arguments and a hash options' do
        expect(instance).to receive(:attachment_style_for).with(:photo, :size, :some => 'options').and_return(:computed_size)

        attachment = double
        expect(attachment).to receive(:url).with(:computed_size, :some => 'options').and_return 'some/url'
        expect(instance).to receive(:photo).and_return(attachment)

        expect(instance.artwork_url(:photo, :size, :some => 'options')).to eq 'some/url'
      end

      it 'works with two arguments only without any options hash' do
        expect(instance).to receive(:attachment_style_for).with(:photo, :size, {}).and_return(:computed_size)

        attachment = double
        expect(attachment).to receive(:url).with(:computed_size, {}).and_return 'some/url'
        expect(instance).to receive(:photo).and_return(attachment)

        expect(instance.artwork_url(:photo, :size)).to eq 'some/url'
      end
    end

    describe 'with real attachment' do
      before :each do
        Artwork.base_resolution    = 1000
        Artwork.current_resolution = 1000
        Artwork.actual_resolution  = 1000
        Artwork.load_2x_images     = false
      end

      it 'will build an url' do
        expect(instance.artwork_url(attachment_name, '320x')).to start_with '/avatar-320x.jpg'
        expect(instance.artwork_url(attachment_name, '320x', {1000 => '1x@2'})).to start_with '/avatar-640x.jpg'

        Artwork.load_2x_images = true
        expect(instance.artwork_url(attachment_name, '320x')).to start_with '/avatar-320x_2x.jpg'
      end
    end
  end

  describe '#attachment_style_for' do
    before :each do
      Artwork.base_resolution    = 1000
      Artwork.current_resolution = 1000
      Artwork.actual_resolution  = 1000
      Artwork.load_2x_images     = false
    end

    def expect_thumb(size, expected)
      expect(instance.attachment_style_for(attachment_name, *Array(size))).to eq expected
    end

    it 'picks the exact requested size if it exists' do
      expect_thumb '2000x', :'2000x'
    end

    it 'accepts sizes passed as both a symbol or a string' do
      expect_thumb '2000x', :'2000x'
      expect_thumb :'2000x', :'2000x'
    end

    it 'scales the required size according to current_resolution' do
      Artwork.base_resolution = 1000
      Artwork.current_resolution = 2000

      expect_thumb '1000x', :'2000x'
      expect_thumb '640x',  :'1280x'
    end

    it 'ignores the retina thumbs when looking for a given size' do
      expect_thumb '1500x', :'2000x'
    end

    it 'uses the _2x thumb for retina screens' do
      Artwork.load_2x_images = true
      expect_thumb '640x', :'640x_2x'
      expect_thumb '640x', :'640x_2x'
    end

    it 'uses the non-retina thumb for retina screens if no _2x thumb is available' do
      Artwork.load_2x_images = true
      expect_thumb '2000x', :'2000x'
    end

    it 'passes through unsupported thumb names' do
      expect_thumb 'unsupported', :unsupported

      Artwork.load_2x_images = true
      Artwork.base_resolution = 1000
      Artwork.current_resolution = 5000

      expect_thumb 'unsupported', :unsupported
    end

    it 'picks the nearest non-retina size to our desizred size' do
      expect_thumb '390x', :'640x'
      expect_thumb '420x', :'640x'
    end

    it 'picks the largest available size if requesting a too large thumb' do
      expect_thumb '5000x', :'2000x'
    end

    it 'picks the smallest available size if requesting a too small thumb' do
      expect_thumb '100x', :'320x'
    end

    it 'distinguishes thumbs by the supplied text label' do
      expect_thumb '320x', :'320x'
      expect_thumb '320x_some_label', :'320x_some_label'
      expect_thumb '200x_some_label', :'320x_some_label'
    end

    it 'allows changing the base resolution per request' do
      Artwork.current_resolution = 2000

      expect_thumb '320x@320', :'2000x'
      expect_thumb '320x@640', :'1280x'

      Artwork.current_resolution = 320
      expect_thumb '320x@320', :'320x'
      expect_thumb '320x_some_label@320', :'320x_some_label'
      expect_thumb '200x_some_label@320', :'320x_some_label'
    end

    it 'considers the aspect ratio of the desired thumb' do
      expect_thumb '320x499', :'320x500'
      expect_thumb '319x498', :'320x500'
      Artwork.load_2x_images = true
      expect_thumb '319x498', :'320x500_2x'
      expect_thumb '319x498_crop', :'320x500_crop_2x'
      Artwork.load_2x_images = false
      expect_thumb '319x498_crop', :'320x500_crop'
    end

    it 'returns the largest nonretina thumb with the requested label if no other suitable sizes are found' do
      expect_thumb '20000x_crop', :'320x500_crop'
      Artwork.load_2x_images = true
      expect_thumb '20000x_crop', :'320x500_crop'
    end

    it 'returns the largest nonretina thumb with the requested aspect ratio if no other suitable sizes are found' do
      expect_thumb '8000x10000', :'400x500'
      Artwork.load_2x_images = true
      expect_thumb '8000x10000', :'400x500'
    end

    it 'returns nil if no thumbnail matches the requested aspect ratio' do
      expect_thumb '319x200', nil
    end

    it 'returns nil if no thumbnail matches the requested label' do
      expect_thumb '319x_nonexistant_label', nil
    end

    it 'will return the exact thumb for retina thumbs' do
      expect_thumb '320x_2x', :'320x_2x'
      expect_thumb '310x_2x', nil

      Artwork.current_resolution = 1111
      expect_thumb '320x_2x', :'320x_2x'

      Artwork.load_2x_images = true
      expect_thumb '320x_2x', :'320x_2x'
    end

    context 'with an alternative sizes definition' do
      it 'ignores alternative sizes if current resolution is above all the max resolutions given' do
        Artwork.current_resolution = 1000

        expect_thumb ['320x', {700 => '100x@100'}], :'320x'
      end

      it 'picks the first alternative size if current resolution is smaller than all max resolutions' do
        Artwork.current_resolution = 799

        expect_thumb ['320x', {1280 => '500x', 800 => '1000x'}], :'1280x'
      end

      it 'picks the first alternative size if current resolution is smaller than all max resolutions and supports custom base resolutions' do
        Artwork.current_resolution = 799

        expect_thumb ['320x', {1280 => '50x@100', 800 => '100x@100'}], :'1280x'
      end

      it 'compares resolutions with <=' do
        Artwork.current_resolution = 800

        expect_thumb ['320x', {1280 => '50x@100', 800 => '100x@100'}], :'1280x'
      end

      it 'picks the largest alternative size if current resolution is smaller only than the max resolution given' do
        Artwork.current_resolution = 1200

        expect_thumb ['320x', {1280 => '50x@100', 800 => '100x@100'}], :'640x'
      end

      it 'ignores non-numeric keys' do
        Artwork.current_resolution = 1200

        expect_thumb ['320x', {1280 => '50x@100', 800 => '100x@100', :foo => 'bar'}], :'640x'
      end
    end
  end
end
