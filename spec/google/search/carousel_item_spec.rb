require 'rspec'
require 'nokogiri'
require_relative '../../../lib/google/search/carousel_item'

module Google
  module Search
    describe CarouselItem do
      describe '::new' do
        let(:item_html) { Nokogiri::HTML::DocumentFragment }
        let(:carousel_item) { described_class.new item_html }

        it 'instantiates' do
          expect(carousel_item).to be_a described_class
        end
      end

      describe 'instance methods' do
        let(:item_html) { }
        let(:carousel_item) { CarouselItem.new item_html }

        describe '#to_h' do
          subject { carousel_item.to_h }

          context 'item_html has information for all fields' do
            let(:item_html) do
              Nokogiri::HTML(
                '<a class="BVG0Nb OxTOff" href="/search?some_random_text_abc">
                  <div>
                    <div style="width:112px">
                      <div class="l7d08" style="width:112px;height:112px">
                        <img class="h1hFNe" alt="Café Terrace at Night" src="data:image/gif;base64,R0lGOD//yHEAAAICTAEAOw==" style="max-width:112px;max-height:112px" id="dimg_29" data-deferred="1">
                      </div>
                      <div class="RWuggc kCrYT">
                        <div>
                          <div class="BNeawe s3v9rd AP7Wnd">Café Terrace at Night</div>
                        </div>
                        <div>
                          <div class="BNeawe tAd8D AP7Wnd">1888</div>
                        </div>
                      </div>
                    </div>
                  </div>
                </a>'
              ).at('a')
            end
            let(:expected_hash) do
              {
                name: 'Café Terrace at Night',
                extensions: ['1888'],
                link: 'https://www.google.com/search?some_random_text_abc',
                image: 'data:image/gif;base64,R0lGOD//yHEAAAICTAEAOw=='
              }
            end

            it 'is the hash with all values' do
              is_expected.to eq expected_hash
            end
          end

          context 'item_html is missing name' do
            let(:item_html) do
              Nokogiri::HTML(
                '<a class="BVG0Nb OxTOff" href="/search?some_random_text_abc">
                  <div>
                    <div style="width:112px">
                      <div class="l7d08" style="width:112px;height:112px">
                        <img class="h1hFNe" alt="Café Terrace at Night" src="data:image/gif;base64,R0lGOD//yHEAAAICTAEAOw==" style="max-width:112px;max-height:112px" id="dimg_29" data-deferred="1">
                      </div>
                      <div class="RWuggc kCrYT">
                        <div>
                          <div class="BNeawe s3v9rd AP7Wnd"></div>
                        </div>
                        <div>
                          <div class="BNeawe tAd8D AP7Wnd">1888</div>
                        </div>
                      </div>
                    </div>
                  </div>
                </a>'
              ).at('a')
            end
            let(:expected_hash) do
              {
                name: 'Café Terrace at Night',
                extensions: ['1888'],
                link: 'https://www.google.com/search?some_random_text_abc',
                image: 'data:image/gif;base64,R0lGOD//yHEAAAICTAEAOw=='
              }
            end

            it 'is the hash with img alt value for name' do
              is_expected.to eq expected_hash
            end
          end

          context 'item_html is empty' do
            let(:item_html) do
              Nokogiri::HTML(
                ''
              )
            end
            let(:expected_hash) do
              {
                name: nil,
                extensions: [nil],
                link: nil,
                image: nil
              }
            end

            it 'is the hash with no values' do
              is_expected.to eq expected_hash
            end
          end
        end

        describe '#errors' do
          subject { carousel_item.errors }

          it 'is the errors' do
            is_expected.to eq []
          end
        end
      end
    end
  end
end
