module Superview
  module Assignable
    # Include in RESTful Rails controllers to assign instance variables ActiveRecord scopes
    # without all the boiler plate.
    #
    # Let's start with the most simple example
    #
    # ```ruby
    # ./app/controllers/blog/posts_controller.rb
    # class BlogsController < ApplicationController
    #   assign :blog
    # end
    # ```
    #
    # This would load the `Blog` scope for `collection` routes, like `index`, as `@blogs` and
    # load `Blog.find(params[:id])` for `member` routes, like `show`, `edit`, `update`, etc.
    # as `@blog`.
    #
    # Most applications need to load stuff from a user that's logged in, which is what the `from:`
    # key makes possible.
    #
    # ```ruby
    # ./app/controllers/blog/posts_controller.rb
    # class BlogsController < ApplicationController
    #   assign :blog, from: :current_user
    # end
    # ```
    #
    # This assumes the controller has a `current_user` method defined in the controller that returns
    # a `User` model with the relationship `has_many :blogs`. It loads the blog via
    # `current_user.blogs.find(params[:id]).
    #
    # A blog has many posts, so how would we assign a post through a blog from the current user?
    #
    # ```ruby
    # ./app/controllers/blog/posts_controller.rb
    # class Blog::PostsController < ApplicationController
    #   assign :post, through: :blog, from: :current_user
    # end
    # ```
    #
    # This does not work like the `through:` ActiveRecord key, so pay attention ya know it all! This
    # follows the idea of nested REST routes in Rails. In this case the `Blog` is the "parent resource"
    # and the `Post` is the resource. How does is that queried? Glad you asked!
    #
    # First the specific blog is loaded via `@blog = current_user.blogs.find(params[:blog_id])` to set the
    # parent model. Next the `Post` scope is set via `@posts = @blog.posts`. `@posts` for collection routes.
    # Finally `@post = @posts.find(params[:id])` is set for member routes.

    extend ActiveSupport::Concern

    included do
      class_attribute :model, :parent_model, :context_method_name

      before_action :assign_parent_collection, if: :has_parent_model?
      before_action :assign_parent_member, if: :has_parent_model_instance?
      before_action :assign_collection, if: :has_model?
      before_action :assign_member, if: :has_model?
    end

    protected

    def assign_collection
      instance_variable_set "@#{model.model_name.plural}", model_scope
    end

    def assign_parent_collection
      instance_variable_set "@#{parent_model.model_name.plural}", parent_model_scope
    end

    def model_scope
      if has_parent_model_instance?
        parent_model_instance.association(model.model_name.collection)
      elsif has_assignable_context?
        assignable_context.association(model.model_name.collection).scope
      else
        model.scope_for_association
      end
    end

    def parent_model_scope
      if has_assignable_context?
        assignable_context.association(parent_model.model_name.collection)
      else
        parent_model.scope_for_association
      end
    end

    def parent_model_instance
      parent_model_scope.find(params.fetch(parent_model_param_key))
    end

    def assign_parent_member
      instance_variable_set "@#{parent_model.model_name.singular}", parent_model_instance
    end

    def has_parent_model?
      parent_model.present?
    end

    def has_parent_model_instance?
      has_parent_model? && params.key?(parent_model_param_key)
    end

    def has_model?
      model.present?
    end

    def assign_member
      instance_variable_set "@#{model.model_name.singular}", model_instance
    end

    def model_instance
      if member?
        model_scope.find params.fetch(model_param_key)
      else
        model_scope.build.tap do |post|
          # # Blog is a reflection of User
          # # Get the name of the `user` association.
          # parent_from_association = parent_model_scope.reflection.inverse_of

          # if model.reflect_on_association(parent_from_association.name)
          #   similar_association = model.association parent_from_association.name
          #   # Now let's see if that association exists on the current_model ..
          #   #
          #   # This isn't setting the foreign key ... errrggggg.
          #   raise 'hell'

          #   # post.association(association_name).target = parent_model_scope.owner
          # end
        end
      end
    end

    def member?
      params.key? model_param_key
    end

    def model_param_key
      :id
    end

    def parent_model_param_key
      "#{parent_model.model_name.singular}_id".to_sym
    end

    def assignable_context
      self.send self.class.context_method_name
    end

    def has_assignable_context?
      !!self.class.context_method_name
    end

    class_methods do
      def assign(scope, through: nil, from: nil)
        self.model = Assignable.find_scope scope
        self.parent_model = Assignable.find_scope through
        self.context_method_name = from
      end
    end

    def self.find_scope(name)
      name.to_s.singularize.camelize.constantize if name
    end
  end
end