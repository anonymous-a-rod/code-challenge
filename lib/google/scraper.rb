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
      @carousel_json ||= carousel.json
    end

    def errors
      return google_search_errors unless valid_google_search_path?
      return response_errors unless response_ok?
      @errors ||= carousel.errors
    end

  private
    attr_accessor :url_path, :carousel_constructor, :httparty_constructor,
      :nokogiri_html_constructor

    def carousel
      @carousel ||= carousel_constructor.new document
    end

    def document
      nokogiri_html_constructor.parse response.body
    end

    def response_errors
      @response_errors ||=
        ["Response code: #{response.code}, message: #{response.message}"]
    end

    def response_ok?
      @response_ok ||= response.code == 200
    end

    def response
      @response ||= httparty_constructor.get url_path
    end

    def google_search_errors
      @google_search_errors ||=
        ["Invalid Google search path, URL must begin with 'https://www.google.com/search?'"]
    end

    def valid_google_search_path?
      @valid_google_search_path ||=
        url_path.start_with? 'https://www.google.com/search?'
    end
  end
end
