module Superview
  module Turbo
    # Renders the metatags for setting up Turbo Drive.
    class MetaTags < ApplicationComponent
      attr_accessor \
        :method,
        :scroll,
        :exempts_page_from_cache,
        :exempts_page_from_preview,
        :page_requires_reload

      METHOD = :replace
      SCROLL = :reset

      def initialize(method: METHOD, scroll: SCROLL, exempts_page_from_preview: nil, exempts_page_from_cache: nil, page_requires_reload: nil)
        refreshes_with method: method, scroll: scroll
        @exempts_page_from_cache = exempts_page_from_cache
        @exempts_page_from_preview = exempts_page_from_preview
        @page_requires_reload = page_requires_reload
      end

      def template
        meta(name: "turbo-refresh-method", content: @method)
        meta(name: "turbo-refresh-scroll", content: @scroll)
        meta(name: "turbo-cache-control", content: "no-cache") if @exempts_page_from_cache
        meta(name: "turbo-cache-control", content: "no-preview") if @exempts_page_from_preview
        meta(name: "turbo-visit-control", content: "reload") if @page_requires_reload
      end

      def refreshes_with(method: METHOD, scroll: SCROLL)
        self.method = method
        self.scroll = scroll
      end

      def method=(value)
        raise ArgumentError, "Invalid refresh option '#{value}'" unless value.in?(%i[ replace morph ])
        @method = value
      end

      def scroll=(value)
        raise ArgumentError, "Invalid scroll option '#{value}'" unless value.in?(%i[ reset preserve ])
        @scroll = value
      end
    end

    module Helpers
      extend ActiveSupport::Concern

      included do
        register_element :turbo_cable_stream_source
      end

      class_methods do
        def turbo(*args, **kwargs, &block)
          @turbo_meta_tags = MetaTags.new(*args, **kwargs)
          define_method(:turbo, &block) if block
        end

        def turbo_meta_tags
          @turbo_meta_tags ||= MetaTags.new
        end
      end

      def turbo_stream_from(*streamables, **attributes)
        attributes[:channel] = attributes[:channel]&.to_s || "Turbo::StreamsChannel"
        attributes[:"signed-stream-name"] = ::Turbo::StreamsChannel.signed_stream_name(streamables)
        turbo_cable_stream_source **attributes, class: "hidden", style: "display: none;"
      end

      def stream_from(*streamables)
        streamables.each do |streamable|
          case streamable
            in association: ActiveRecord::Relation
              association.each { turbo_stream_from streamable }
            else
              turbo_stream_from streamable
          end
        end
      end
    end
  end
end
