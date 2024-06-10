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

# NOTE: 3 example searches

# Google search: Vincent Van Gogh
# html_path = 'https://www.google.com/search?q=vincent+van+gogh&sca_esv=b5e39c1845ece73b&sxsrf=ADLYWII-jheeFbltS6Cfh254BDAS5DEVCg%3A1717941448874&source=hp&ei=yLRlZr2RM662ptQP_8qnsAc&iflsig=AL9hbdgAAAAAZmXC2EWPrmhFfesgHP4_fOyrL-oVr6fE&oq=vincent+van+gough&gs_lp=Egdnd3Mtd2l6GgIYAiIRdmluY2VudCB2YW4gZ291Z2gqAggAMgcQIxixAhgnMgoQLhiABBixAxgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKMgcQABiABBgKSJEcUABY1BJwAHgAkAEAmAGRAaAB9Q2qAQM4Ljm4AQPIAQD4AQGYAhGgAqgOwgIEECMYJ8ICChAuGIAEGCcYigXCAgoQIxiABBgnGIoFwgILEAAYgAQYkQIYigXCAg4QLhiABBjHARiOBRivAcICDhAuGIAEGLEDGNEDGMcBwgIREC4YgAQYsQMY0QMYgwEYxwHCAgsQLhiABBixAxiDAcICChAAGIAEGEMYigXCAhcQLhiABBixAxjRAxjSAxjHARioAxiLA8ICERAAGIAEGLEDGIMBGIoFGIsDwgIUEC4YgAQYsQMYqAMYmAMYmgMYiwPCAgsQABiABBixAxiLA8ICFxAuGIAEGLEDGIMBGKgDGJgDGJoDGIsDwgIIEAAYgAQYiwPCAgsQABiABBixAxiDAcICFBAuGIAEGKYDGMcBGKgDGIsDGK8BwgIIEC4YgAQYsQPCAhcQLhiABBixAxiDARioAxiaAxiLAxibA8ICGRAuGIAEGEMYpgMYxwEYqAMYigUYiwMYrwHCAhQQLhiABBixAxiYAxioAxiaAxiLA8ICGRAuGIAEGLEDGEMYmAMYqAMYigUYmgMYiwPCAhQQLhiABBixAxiDARijAxioAxiLA8ICERAuGIAEGLEDGKgDGJoDGIsDwgIXEC4YgAQYsQMYgwEYmAMYqAMYmgMYiwPCAhEQLhiABBixAxioAxiLAxjuBcICBRAAGIAEwgIOEC4YgAQYsQMYgwEYigWYAwDiAwUSATEgQJIHBDcuMTCgB7SQAg&sclient=gws-wiz'

# Google search: Frank Lloyd Wright
# html_path = 'https://www.google.com/search?q=frank+lloyd+wright&sca_esv=23275d10bb72eb94&sxsrf=ADLYWIJIZFBXGft5dw78_-oPFv7dbvhUGw%3A1717961343369&ei=fwJmZpSgFqTcptQPjfG0qQk&gs_ssp=eJzj4tDP1TcwKs_JNmD0EkorSszLVsjJya9MUSgvykzPKAEAkFAKJg&oq=frank+&gs_lp=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&sclient=gws-wiz-serp'

# Google search: Pablo Picasso
# html_path = 'https://www.google.com/search?q=Pablo+Picasso&sca_esv=23275d10bb72eb94&sxsrf=ADLYWIJS4Rais4CTJrbllSUlmQr7jsokZA%3A1717961805921&ei=TQRmZvbyN6vdptQP7e2s8AE&ved=0ahUKEwi2zbe5os-GAxWrrokEHe02Cx4Q4dUDCBA&uact=5&oq=Pablo+Picasso&gs_lp=Egxnd3Mtd2l6LXNlcnAiDVBhYmxvIFBpY2Fzc28yChAjGIAEGCcYigUyDRAuGIAEGLEDGEMYigUyDRAAGIAEGLEDGEMYigUyChAAGIAEGEMYigUyChAAGIAEGEMYigUyCBAAGIAEGLEDMgoQABiABBhDGIoFMgUQABiABDIKEAAYgAQYQxiKBTIFEAAYgAQyHBAuGIAEGLEDGEMYigUYlwUY3AQY3gQY3wTYAQFI1QVQAFgAcAB4AZABAJgBeKABeKoBAzAuMbgBA8gBAPgBAvgBAZgCAaACfpgDALoGBggBEAEYFJIHAzAuMaAHvA0&sclient=gws-wiz-serp'

# scraper = Google::Scraper.new html_path

# p scraper.carousel_json
