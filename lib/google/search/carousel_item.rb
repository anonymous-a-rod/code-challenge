require 'nokogiri'

module Google
  module Search
    class CarouselItem
      ITEM_NAME_SELECTOR = '.BNeawe.s3v9rd.AP7Wnd'
      ITEM_DATE_SELECTOR = '.BNeawe.tAd8D.AP7Wnd'

      def initialize(item_html)
        @item_html = item_html
      end

      def to_h
        @to_h ||= { name:, extensions: [date], link:, image: }
      end

    private
      attr_accessor :item_html

      def name
        return name_element.text if name_element && !name_element.text.empty?
        return image_element['alt'] if image_element&.has_attribute? 'alt'
        nil
      end

      def date
        date_element&.text
      end

      def link
        return nil unless item_html.has_attribute? 'href'
        "https://www.google.com#{item_html['href']}"
      end

      def image
        return nil unless image_element&.has_attribute? 'src'
        image_element['src']
      end

      def name_element
        @name_element ||= item_html.at_css ITEM_NAME_SELECTOR
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
