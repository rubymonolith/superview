module Superview
  module Helpers
    module Turbo
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
