require 'spec_helper'

module Artwork
  describe View do
    let(:view_context) { Class.new { include View }.new }

    describe '#activate_resolution_independence' do
      it 'returns an HTML script tag' do
        stub_const('Uglifier', double(:compile => 'compiled_script'))
        expect(Thread).to receive(:current).and_return({})
        expect(view_context).to receive(:content_tag).with(:script, 'compiled_script').and_return('compiled_script_html')

        expect(view_context.activate_resolution_independence).to eq 'compiled_script_html'
      end

      it 'caches the compiled script in Thread.current' do
        expect(Thread).to receive(:current).and_return(:artwork_script => 'cached_compiled_script')
        expect(view_context.activate_resolution_independence).to eq 'cached_compiled_script'
      end
    end

    describe '#artwork_tag' do
      it 'is defined' do
        expect(View.instance_methods.map(&:to_sym)).to include(:artwork_tag)
      end

      it 'returns an HTML img tag with the appropriate URL' do
        record = double
        expect(record).to receive(:artwork_url).with(:artwork_name, :size, {}).and_return('image_url')
        allow(view_context).to receive(:content_tag).and_yield
        expect(view_context).to receive(:image_tag).with('image_url', {:alt => nil}).and_return('image-tag-with-url')

        generated_html = view_context.artwork_tag(record, :artwork_name, :size)

        expect(generated_html).to eq 'image-tag-with-url'
      end

      it 'passes the options to artwork_url' do
        record = double
        expect(record).to receive(:artwork_url).with(:artwork_name, :size, {:some => 'options'}).and_return('image_url')
        allow(view_context).to receive(:content_tag).and_yield
        expect(view_context).to receive(:image_tag).with('image_url', {:alt => nil}).and_return('image-tag-with-url')

        generated_html = view_context.artwork_tag(record, :artwork_name, :size, {:some => 'options'})

        expect(generated_html).to eq 'image-tag-with-url'
      end
    end
  end
end
