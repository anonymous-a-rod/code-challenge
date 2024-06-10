require 'rspec'
require 'nokogiri'
require_relative '../../lib/google/scraper'

module Google
  describe Scraper do
    let(:url_path) { instance_double String }
    let(:carousel_constructor) { class_double Search::Carousel }
    let(:httparty_constructor) { class_double HTTParty }
    let(:nokogiri_html_constructor) { class_double Nokogiri::HTML }
    let(:scraper) do
      described_class.
        new url_path,
          carousel_constructor:,
          httparty_constructor:,
          nokogiri_html_constructor:
    end

    describe '::new' do
      it 'instantiates' do
        expect(scraper).to be_a described_class
      end
    end

    describe 'instance methods' do
      context 'integration specs' do
        shared_context 'allow url' do |valid:|
          let(:url_path) do
            valid ? 'https://www.google.com/search?q=ruby' : 'www.serpapi.com'
          end
        end

        shared_context 'allow response' do |successful:|
          let(:body) { successful ? '<html></html>' : '' }
          let(:successful_response) do
            double 'HTTParty::Response', code: 200, body:, message: 'OK'
          end
          let(:failed_response) do
            double 'HTTParty::Response', code: 404, body: '', message: 'Not Found'
          end
          let(:response) { successful ? successful_response : failed_response }

          before do
            allow(httparty_constructor).to receive(:get).with(url_path).
              and_return response
            allow(response).to receive(:body) { body }
            allow(nokogiri_html_constructor).to receive(:parse) { body }
          end
        end

        shared_context 'allow carousel' do |error:|
          let(:errors) { error ? ['carousel error'] : [] }
          let(:carousel_instance) do
            instance_double Search::Carousel, errors:, json: '{"title": []}'
          end

          before do
            allow(carousel_constructor).to receive(:new) { carousel_instance }
          end
        end

        describe '#carousel_json' do
          subject { scraper.carousel_json }

          context 'with a valid Google search URL' do
            include_context 'allow url', valid: true
            include_context 'allow response', successful: true
            include_context 'allow carousel', error: false

            it 'is the carousel JSON' do
              is_expected.to eq '{"title": []}'
            end
          end
      
          context 'invalid Google search URL' do
            include_context 'allow url', valid: false

            it 'is nil' do
              is_expected.to be_nil
            end
          end
        end

        describe '#errors' do
          subject { scraper.errors }

          context 'invalid Google search URL' do
            include_context 'allow url', valid: false

            it 'is the invalid google url search path error' do
              is_expected.to include 'Invalid Google URL search path'
            end
          end
      
          context 'response is not OK' do
            include_context 'allow url', valid: true
            include_context 'allow response', successful: false

            it 'is the response error message' do
              is_expected.to include 'Response code: 404, message: Not Found'
            end
          end

          context 'has carousel errors' do
            include_context 'allow url', valid: true
            include_context 'allow response', successful: true
            include_context 'allow carousel', error: true

            it 'is the carousel errors' do
              is_expected.to include 'carousel error'
            end
          end

          context 'valid Google search URL and OK response' do
            include_context 'allow url', valid: true
            include_context 'allow response', successful: true
            include_context 'allow carousel', error: false

            it 'is an empty array' do
              is_expected.to be_empty
            end
          end
        end
      end

      context 'unit specs' do
        let(:scraper) { described_class.new url_path }
        # NOTE: the links change each time
        # Due to time constraints, I am writing simple, less comprehensive tests

        context 'Vincent Van Gogh' do
          let(:url_path) do
            'https://www.google.com/search?q=vincent+van+gogh&sca_esv=b5e39c1845ece73b&sxsrf=ADLYWII-jheeFbltS6Cfh254BDAS5DEVCg%3A1717941448874&source=hp&ei=yLRlZr2RM662ptQP_8qnsAc&iflsig=AL9hbdgAAAAAZmXC2EWPrmhFfesgHP4_fOyrL-oVr6fE&oq=vincent+van+gough&gs_lp=Egdnd3Mtd2l6GgIYAiIRdmluY2VudCB2YW4gZ291Z2gqAggAMgcQIxixAhgnMgoQLhiABBixAxgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKSJEcUABY1BJwAHgAkAEAmAGRAaAB9Q2qAQM4Ljm4AQPIAQD4AQGYAhGgAqgOwgIEECMYJ8ICChAuGIAEGCcYigXCAgoQIxiABBgnGIoFwgILEAAYgAQYkQIYigXCAg4QLhiABBjHARiOBRivAcICDhAuGIAEGLEDGNEDGMcBwgIREC4YgAQYsQMY0QMYgwEYxwHCAgsQLhiABBixAxiDAcICChAAGIAEGEMYigXCAhcQLhiABBixAxjRAxjSAxjHARioAxiLA8ICERAAGIAEGLEDGIMBGIoFGIsDwgIUEC4YgAQYsQMYqAMYmAMYmgMYiwPCAgsQABiABBixAxiLA8ICFxAuGIAEGLEDGIMBGKgDGJgDGJoDGIsDwgIIEAAYgAQYiwPCAgsQABiABBixAxiDAcICFBAuGIAEGKYDGMcBGKgDGIsDGK8BwgIIEC4YgAQYsQPCAhcQLhiABBixAxiDARioAxiaAxiLAxibA8ICGRAuGIAEGEMYpgMYxwEYqAMYigUYiwMYrwHCAhQQLhiABBixAxiYAxioAxiaAxiLA8ICGRAuGIAEGLEDGEMYmAMYqAMYigUYmgMYiwPCAhQQLhiABBixAxiDARijAxioAxiLA8ICERAuGIAEGLEDGKgDGJoDGIsDwgIXEC4YgAQYsQMYgwEYmAMYqAMYmgMYiwPCAhEQLhiABBixAxioAxiLAxjuBcICBRAAGIAEwgIOEC4YgAQYsQMYgwEYigWYAwDiAwUSATEgQJIHBDcuMTCgB7SQAg&sclient=gws-wiz'
          end

          # REFERENCE:
          # "{\"Artworks\":[{\"name\":\"The Starry Night\",\"extensions\":[\"1889\"],\"link\":\"https://www.google.com/search?sca_esv=b5e39c1845ece73b&ie=UTF-8&q=The+Starry+Night&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMzC3jC7WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYBUIyUhWCSxKLiioV_DLTM0oAdKX0-E4AAAA&sa=X&ved=2ahUKEwixx76C5s-GAxVIrokEHY4bLFwQ0I4BegQIDBAd\",\"image\":\"data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"},{\"name\":\"Van Gogh self-portrait\",\"extensions\":[\"1889\"],\"link\":\"https://www.google.com/search?sca_esv=b5e39c1845ece73b&ie=UTF-8&q=Van+Gogh+self-portrait&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLi1k_XNzQyTEk2z8nTUspOttIvyywuTcyJTywqQWJmFpdYlecXZRcvYhULS8xTcM9Pz1AoTs1J0y3ILyopSswsAQAjTSJSVgAAAA&sa=X&ved=2ahUKEwixx76C5s-GAxVIrokEHY4bLFwQ0I4BegQIDBAf\",\"image\":\"data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"},{\"name\":\"The Potato Eaters\",\"extensions\":[\"1885\"],\"link\":\"https://www.google.com/search?sca_esv=b5e39c1845ece73b&ie=UTF-8&q=The+Potato+Eaters&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMTCxMKrWUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYBUMyUhUC8ksSS_IVXBNLUouKAa5xmdtPAAAA&sa=X&ved=2ahUKEwixx76C5s-GAxVIrokEHY4bLFwQ0I4BegQIDBAh\",\"image\":\"data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"},{\"name\":\"Wheatfield with Crows\",\"extensions\":[\"1890\"],\"link\":\"https://www.google.com/search?sca_esv=b5e39c1845ece73b&ie=UTF-8&q=Wheatfield+with+Crows&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMkw0KirWUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYRcMzUhNL0jJTc1IUyjNLMhSci_LLiwHOVDeyUwAAAA&sa=X&ved=2ahUKEwixx76C5s-GAxVIrokEHY4bLFwQ0I4BegQIDBAj\",\"image\":\"data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"},{\"name\":\"Irises\",\"extensions\":[\"1889\"],\"link\":\"https://www.google.com/search?sca_esv=b5e39c1845ece73b&ie=UTF-8&q=Irises+(painting)&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLGMzUvMi7WUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYBT2LMotTixU0ChIz80oy89I1ATgwCCtPAAAA&sa=X&ved=2ahUKEwixx76C5s-GAxVIrokEHY4bLFwQ0I4BegQIDBAl\",\"image\":\"data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"},{\"name\":\"Café Terrace at Night\",\"extensions\":[\"1888\"],\"link\":\"https://www.google.com/search?sca_esv=b5e39c1845ece73b&ie=UTF-8&q=Caf%C3%A9+Terrace+at+Night&stick=H4sIAAAAAAAAAONgFuLQz9U3MI_PNVLiBLFMyg2NLbSUspOt9Msyi0sTc-ITi0qQmJnFJVbl-UXZxYtYxZwT0w6vVAhJLSpKTE5VSCxR8MtMzygBABqaicVUAAAA&sa=X&ved=2ahUKEwixx76C5s-GAxVIrokEHY4bLFwQ0I4BegQIDBAn\",\"image\":\"data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==\"}]}"

          describe '#carousel_json' do
            subject { scraper.carousel_json}

            it 'is has the title' do
              is_expected.to include 'Artworks'
            end

            it 'includes "The Starry Night"' do
              is_expected.to include 'The Starry Night'
              is_expected.to include '1889'
            end

            it 'includes "Wheatfield with Crows"' do
              is_expected.to include '"Wheatfield with Crows"'
              is_expected.to include '1889'
            end
          end
        end

        context 'Frank Lloyd Wright' do
          let(:url_path) do
            'https://www.google.com/search?q=frank+lloyd+wright&sca_esv=23275d10bb72eb94&sxsrf=ADLYWIJIZFBXGft5dw78_-oPFv7dbvhUGw%3A1717961343369&ei=fwJmZpSgFqTcptQPjfG0qQk&gs_ssp=eJzj4tDP1TcwKs_JNmD0EkorSszLVsjJya9MUSgvykzPKAEAkFAKJg&oq=frank+&gs_lp=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&sclient=gws-wiz-serp'
          end

          describe '#carousel_json' do
            subject { scraper.carousel_json}

            it 'is has the title' do
              is_expected.to include 'Structures'
            end

            it 'includes "Fallingwater"' do
              is_expected.to include 'Fallingwater'
            end

            it 'includes "Taliesin West"' do
              is_expected.to include 'Taliesin West'
            end
          end
        end

        context 'Michelangelo' do
          let(:url_path) do
            'https://www.google.com/search?q=michelangeo&sca_esv=23275d10bb72eb94&biw=1440&bih=819&sxsrf=ADLYWIJmghqYh9pMsbTe9VFvZARPY4kBTQ%3A1717984996017&ei=5F5mZrJgwKmm1A_MvpGQCA&ved=0ahUKEwiy4qrr-M-GAxXAlIkEHUxfBIIQ4dUDCBA&uact=5&oq=michelangeo&gs_lp=Egxnd3Mtd2l6LXNlcnAaAhgCIgttaWNoZWxhbmdlbzINEC4YgAQYsQMYQxiKBTINEAAYgAQYsQMYQxiKBTIKEAAYgAQYQxiKBTIQEC4YgAQYsQMYxwEYChivATINEC4YgAQYsQMYQxiKBTIKEAAYgAQYQxiKBTIKEAAYgAQYQxiKBTIKEAAYgAQYQxiKBTINEAAYgAQYsQMYQxiKBTIQEC4YgAQYsQMYxwEYChivATIcEC4YgAQYsQMYQxiKBRiXBRjcBBjeBBjfBNgBAUj7FVAAWPYScAB4AZABAJgBgAGgAfwIqgEDNS42uAEDyAEA-AEBmAILoAKqCcICChAuGIAEGCcYigXCAgoQIxiABBgnGIoFwgIEECMYJ8ICChAuGIAEGEMYigXCAhcQLhiABBiKBRiXBRjcBBjeBBjfBNgBAcICGhAuGIAEGLEDGIMBGKYDGMcBGKgDGIsDGK8BwgIOEC4YgAQYsQMYxwEYrwHCAggQLhiABBixA5gDALoGBggBEAEYFJIHAzIuOaAHzYMC&sclient=gws-wiz-serp'
          end

          describe '#carousel_json' do
            subject { scraper.carousel_json}

            it 'is has the title' do
              is_expected.to include 'Artworks'
            end

            it 'includes "Sistine Chapel ceiling"' do
              is_expected.to include 'Sistine Chapel ceiling'
              is_expected.to include '1512'
            end

            it 'includes "David"' do
              is_expected.to include 'David'
              is_expected.to include '1504'
            end
          end
        end
      end
    end
  end
end
