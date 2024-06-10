require 'httparty'
require 'nokogiri'
require_relative './search/carousel'

module Google
  class Scraper
    def initialize(url_path,
                   carousel_constructor: Search::Carousel,
                   httparty_constructor: HTTParty,
                   nokogiri_html_constructor: Nokogiri::HTML)
      @url_path = url_path
      @carousel_constructor = carousel_constructor
      @httparty_constructor = httparty_constructor
      @nokogiri_html_constructor = nokogiri_html_constructor
    end

    def carousel_json
      return nil unless errors.empty?
      carousel.json
    end

    def errors
      return ["Invalid Google URL search path"] unless valid_google_search_path?
      return ["Response code: #{response.code}, message: #{response.message}"] unless response_ok?
      @errors ||= carousel_errors
    end

  private
    attr_accessor :carousel_constructor, :httparty_constructor,
      :nokogiri_html_constructor
    attr_reader :url_path

    def carousel
      @carousel ||= carousel_constructor.new document
    end

    def carousel_errors
      @carousel_errors ||= carousel.errors
    end

    def valid_google_search_path?
      url_path.start_with? 'https://www.google.com/search?'
    end

    def response_ok?
      response.code == 200
    end

    def response
      @response ||= httparty_constructor.get url_path
    end

    def document
      nokogiri_html_constructor.parse response.body
    end
  end
end
