module Superview::Components
  # Renders an HTML table for a collection. Each item is passed into the
  # collection of the table.
  #
  # ```ruby
  # render TableComponent.new(@posts) do |table|
  #   # This is how you'd usually render a table.
  #   table.column("Title") { show(_1, :title) }
  #
  #   # If you need to render HTML in the title, add a `column` argument
  #   # to the block and call `title` or `item` on it.
  #   table.column do |column|
  #     # Titles might not always be text, so we need to handle rendering
  #     # Phlex markup within.
  #     column.title do
  #       link_to(user_blogs_path(@current_user)) { "Blogs" }
  #     end
  #     column.item { show(_1.blog, :title) }
  #   end
  # end
  # ```
  class TableComponent < ApplicationComponent
    include Phlex::DeferredRender

    class Column
      attr_accessor :title_template, :item_template

      def title(&block)
        @title_template = block
      end

      def item(&block)
        @item_template = block
      end

      def self.build(title:, &block)
        new.tap do |column|
          column.title { title }
          column.item(&block)
        end
      end
    end

    def initialize(items = [], **attributes)
      @items = items
      @attributes = attributes
      @columns = []
    end

    def view_template(&)
      table(**@attributes) do
        thead do
          tr do
            @columns.each do |column|
              th(&column.title_template)
            end
          end
        end
        tbody do
          @items.each do |item|
            tr do
              @columns.each do |column|
                td { column.item_template.call(item) }
              end
            end
          end
        end
      end
    end

    def column(title = nil, &block)
      @columns << if title
        Column.build(title: title, &block)
      else
        Column.new.tap(&block)
      end
    end
  end
end
