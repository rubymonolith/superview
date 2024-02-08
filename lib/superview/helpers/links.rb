module Superview
  module Helpers
    # RESTful links for creating Superviews in applications. For example, given a
    # blog application, we might have links like:
    #
    # ```ruby
    # create(Post) { "New Blog Post" }
    # create(Post.new) { "New Blog Post" }
    # ```
    #
    # Which generateds the html `<a href="/posts/new">New Blog Post</a>` and
    #
    # ```ruby
    # show(@post) { @post.title }
    # ```
    #
    # generates the html `<a href="/posts/1">My First Post</a>`. An attribute
    # can be passed in as a second argument, which calls the method on the object
    # passed into the link helper.
    #
    # ```ruby
    # show(@post, :title)
    # ```
    #
    # generates `<a href="/posts/new">New Blog Post</a>`.
    #
    # Link helpers are available per RESTful action.
    #
    # ```ruby
    # delete(@post)
    # edit(@post)
    # ```
    module Links
      # Give us some sane link helpers to work with in Phlex. They kind
      # of mimic Rails helpers, but are "Phlexable".
      def link_to(target = nil, method: nil, **attributes, &)
        url = case target
        when URI
          target.to_s
        when NilClass
          url_for(attributes)
        else
          url_for(target)
        end
        a(href: url, data_turbo_method: method, **attributes, &)
      end

      def show(model, attribute = nil, *args, **kwargs, &content)
        content ||= Proc.new { model.send(attribute) }
        link_to(model, *args, **kwargs, &content)
      end

      def edit(model, *args, **kwargs, &content)
        content ||= Proc.new { "Edit #{model.class.model_name}" }
        link_to([:edit, model],  *args, **kwargs, &content)
      end

      def delete(model, *args, confirm: nil, **kwargs, &content)
        content ||= Proc.new { "Delete #{model.class.model_name}" }
        link_to(model, *args, method: :delete, data_turbo_confirm: confirm, **kwargs, &content)
      end

      def create(scope = nil, *args, **kwargs, &content)
        target = if scope.respond_to? :proxy_association
          owner = scope.proxy_association.owner
          model = scope.proxy_association.reflection.klass.model_name
          element = scope.proxy_association.reflection.klass.model_name.element.to_sym
          [:new, owner, element]
        elsif scope.respond_to? :model
          model = scope.model
          [:new, model.model_name.singular_route_key.to_sym]
        elsif scope.respond_to? :model_name
          [:new, scope.model_name.singular_route_key.to_sym]
        end

        content ||= Proc.new { "Create #{model}" }

        link_to(target, *args, **kwargs, &content)
      end
    end
  end
end