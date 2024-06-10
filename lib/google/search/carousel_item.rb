require 'nokogiri'

module Google
  module Search
    class CarouselItem
      ITEM_TITLE_SELECTOR = '.BNeawe.s3v9rd.AP7Wnd'
      ITEM_DATE_SELECTOR = '.BNeawe.tAd8D.AP7Wnd'

      def initialize(item_html)
        @item_html = item_html
      end

      def to_h
        @to_h ||=
          {
            "name": title,
            "extensions": [
              date
            ],
            "link": link,
            "image": image
          }
      end

      def errors
        @errors ||= []
      end

    private
      attr_reader :item_html

      def title
        return title_element.text if title_element && !title_element.text.empty?
        return image_element['alt'] if image_element&.has_attribute? 'alt'
        nil
      end

      def date
        return date_element&.text if date_element
        nil
      end

      def link
        return "https://www.google.com#{item_html['href']}" if item_html.has_attribute? 'href'
        nil
      end

      def image
        return image_element['src'] if image_element&.has_attribute? 'src'
        nil
      end

      def title_element
        @title_element ||= item_html.at_css ITEM_TITLE_SELECTOR
      end

      def date_element
        @date_element ||= item_html.at_css ITEM_DATE_SELECTOR
      end

      def image_element
        @image_element ||= item_html.at 'img'
      end
    end
  end
end
