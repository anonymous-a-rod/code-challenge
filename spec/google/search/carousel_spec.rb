require 'rspec'
require 'nokogiri'
require_relative '../../../lib/google/search/carousel'

module Google
  module Search
    describe Carousel do
      let(:document) { instance_double Nokogiri::HTML::DocumentFragment }
      let(:carousel_item_constructor) { class_double CarouselItem }
      let(:carousel) do
        described_class.new document, carousel_item_constructor:
      end

      describe '::new' do
        it 'instantiates' do
          expect(carousel).to be_a described_class
        end
      end

      describe 'instance methods' do
        shared_context 'allow carousel_container' do
          let(:carousel_container) do
            instance_double Nokogiri::HTML::DocumentFragment
          end

          before do
            allow(document).to receive(:at_css).with(".Xdlr0d").
              and_return carousel_container
            allow(document).to receive(:at_css).with(".BNeawe.wyrwXc.AP7Wnd").
              and_return carousel_container
            allow(carousel_container).to receive(:css).with(".BVG0Nb.OxTOff").
              and_return []
          end
        end

        shared_context 'allow carousel_item' do
          let(:carousel_item) do
            instance_double Nokogiri::HTML::DocumentFragment
          end

          before do
            allow(carousel).to receive(:carousel_array) { [{}] }
            allow(carousel_container).to receive(:css).with(".BVG0Nb.OxTOff").
              and_return [carousel_item]
            allow(CarouselItem).to receive(:new) { carousel_item }
            allow(carousel_item).to receive(:to_h)
          end
        end

        shared_context 'allow title' do |title|
          let(:has_title) { !title.nil? }
          let(:title_element) do
            has_title ? instance_double(Nokogiri::HTML::DocumentFragment) : nil
          end

          before do
            allow(document).to receive(:at_css).with('.BNeawe.wyrwXc.AP7Wnd').
              and_return title_element
            allow(title_element).to receive(:text) { title } if title_element
          end
        end

        describe '#json' do
          subject { carousel.json }

          context 'has errors' do
            before do
              allow(carousel).to receive(:errors) { ['No carousel detected'] }
            end

            it { is_expected.to be_nil }
          end

          context 'no errors' do
            include_context 'allow carousel_container'
            include_context 'allow carousel_item'

            context 'no title element' do
              include_context 'allow title', nil
  
              it 'is the JSON with "Uknown Title"' do
                is_expected.to eq({ 'Unknown Title' => [{}] }.to_json)
              end
            end

            context 'title is empty' do
              include_context 'allow title', ''
  
              it 'is the JSON with "Uknown Title"' do
                is_expected.to eq({ 'Unknown Title' => [{}] }.to_json)
              end
            end

            context 'title is present' do
              include_context 'allow title', 'Sample Title'
  
              it 'is the JSON with the title' do
                is_expected.to eq({ 'Sample Title' => [{}] }.to_json)
              end
            end
          end
        end

        describe '#errors' do
          subject { carousel.errors }

          context 'carousel not detected' do
            let(:carousel_container) { nil }

            before do
              allow(document).to receive(:at_css).with(".Xdlr0d").
                and_return carousel_container
            end

            it 'is the no carousel detected error message' do
              is_expected.to eq ['No carousel detected']
            end
          end

          context 'carousel is detected but failed to extract data' do
            include_context 'allow carousel_container'

            it 'is the carousel detected, but failed to extract data error message' do
              is_expected.to eq ['Carousel detected, but failed to extract data']
            end
          end

          context 'carousel is detected and data extraction is successful' do
            include_context 'allow carousel_container'
            include_context 'allow carousel_item'
            include_context 'allow title', title: 'something'

            it 'is empty' do
              is_expected.to eq []
            end
          end
        end
      end
    end
  end
end
