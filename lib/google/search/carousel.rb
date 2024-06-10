require 'nokogiri'
require_relative 'carousel_item'
require 'json'

module Google
  module Search
    class Carousel
      CAROUSEL_CONTAINER_CLASS = '.Xdlr0d'
      CAROUSEL_ITEM_CLASS = '.BVG0Nb.OxTOff'
      CAROUSEL_TITLE_CLASS = '.BNeawe.wyrwXc.AP7Wnd'

      def initialize(document,
                     carousel_item_constructor: CarouselItem)
        @document = document
        @carousel_item_constructor = carousel_item_constructor
      end

      def json
        return nil unless errors.empty?
        @json ||= { title => carousel_array }.to_json
      end

      def errors
        return @errors if defined? @errors
        return @errors = ['No carousel detected'] unless carousel_container
        return @errors = ['Carousel detected, but failed to extract data'] if carousel_array.empty?
        @errors = []
      end

    private
      attr_accessor :document, :carousel_item_constructor

      def carousel_container
        @carousel_container ||= document.at_css CAROUSEL_CONTAINER_CLASS
      end

      def carousel_array
        carousel_container.css(CAROUSEL_ITEM_CLASS).inject([]) do |array, item|
          carousel_item = carousel_item_for item
          array << carousel_item.to_h
        end
      end

      def carousel_item_for(item)
        carousel_item_constructor.new item
      end

      def title
        text = ''
        text = title_element.text if title_element
        return text unless text.nil? || text.empty?
        @title = 'Unknown Title'
      end

      def title_element
        @title_element ||= document.at_css CAROUSEL_TITLE_CLASS
      end
    end
  end
end
