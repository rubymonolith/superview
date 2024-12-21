# Superview

> ## 🏗️ Work in progress 👷‍♂️
> These docs show what Superview will look like when it supports ViewComponent. The docs for the current gem, 0.1.3, that's phlex only is at https://github.com/rubymonolith/superview/blob/v0.1.3/README.md.

Build Rails applications, from the ground up, using [Phlex](https://www.phlex.fun/) or [ViewComponent](https://viewcomponent.org/) components, like this.

```ruby
# ./app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Superview::Actions

  before_action :load_post

  class Show < ApplicationComponent
    attr_accessor :post

    def view_template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

  class Edit < ViewComponent::Base
    attr_accessor :post

    def call
      <<~HTML
        <h1>Edit #{@post.title}</h1>
        <form action="<%= post_path(@post) %>" method="post">
          <input type="text" name="title" value="<%= @post.title %>">
          <textarea name="body"><%= @post.body %></textarea>
          <button type="submit">Save</button>
        </form>
      HTML
    end
  end

  private
    def load_post
      @post = Post.find(params[:id])
    end
end
```

Read more about it at:

* [Component driven development on Rails with Phlex](https://fly.io/ruby-dispatch/component-driven-development-on-rails-with-phlex/)
* [Hacking Rails Implicit Rendering for View Components & Fun](https://fly.io/ruby-dispatch/hacking-rails-implicit-rendering-for-view-components/)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add superview

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install superview

## Usage

Add `include Superview::Actions` to any controllers you'd like to render components as controller actions.

```ruby
# ./app/controllers/posts_controller.rb
class PostsController < ApplicationController
   # 🚨 Add this 👇 to your controller 🚨
  include Superview::Actions

  # Your code...
end
```

Then add classes to your controller that map to the actions you'd like to render. The `Show` class will render when the `PostsController#show` action is called and the `Edit` class will render when the `PostsController#edit` action is called.

```ruby
# ./app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Superview::Actions

  before_action :load_post

  class Show < ApplicationComponent
    attr_accessor :post

    def view_template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

  class Edit < ViewComponent::Base
    attr_accessor :post

    def call
      <<~HTML
        <h1>Edit #{@post.title}</h1>
        <form action="<%= post_path(@post) %>" method="post">
          <input type="text" name="title" value="<%= @post.title %>">
          <textarea name="body"><%= @post.body %></textarea>
          <button type="submit">Save</button>
        </form>
      HTML
    end
  end

  private
    def load_post
      @post = Post.find(params[:id])
    end
end
```

### Explicit rendering

You can explicitly render a component in a controller action method. In this example, we needed to render a the `Show` component in the `html` format and a JSON response in the `json` format.

```ruby
# ./app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Superview::Actions

  # Your code...

  class Show < ApplicationComponent
    attr_accessor :post

    def view_template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

  def show
    respond_to do |format|
      # 👋 Renders the Show component
      format.html { render component }

      # 👉 These would also work...
      # format.html { render Show.new.tap { _1.post = @post } }
      # format.html { render component Show.new }
      # format.html { render component Show }
      # format.html { render component :show }
      format.json { render json: @post }
    end
  end

  # Your code...
end
```

### Rendering other classes from different actions

It's common to have to render form actions from other actions when forms are saved. In this example the `create` method renders the `component New` view when the form is invalid.

```ruby
# ./app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Superview::Actions

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post
    else
      # 👋 Renders the New component from the create action.
      render component New

      # 👉 These would also work...
      # render New.new.tap { _1.post = @post }
      # render component New.new
      # render component New
      # render component :new
    end
  end

  # Your code...
end
```

### Extracting inline views into the `./app/views` folder

Inline views are an amazingly productive way of prototyping apps, but as it matures you might be inclined to extract these views into the `./app/views` folders for organizational purposes or so you can share them between controllers.

First let's extract the `Show` class into `./app/views/posts/show.rb`

```ruby
# ./app/views/posts/show.rb
module Posts
  class Show < ApplicationComponent
    attr_accessor :post

    def view_template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end
end
```

Then include the `Posts` module in the controllers you'd like to use the views:

```ruby
# ./app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include Superview::Actions
  # 🚨 Add this 👇 to your controller 🚨
  include Posts

  before_action :load_post

  def show
    respond_to do |format|
      format.html { render Show.new.tap { _1.post = @post } }
      format.json { render json: @post }
    end
  end

  private
    def load_post
      @post = Post.find(params[:id])
    end
end
```

That's it! Ruby includes all the classes in the `Posts` module, which Superview picks up and renders in the controller. If you have an `Index`, `Edit`, `New`, etc. class in the `Posts` namespace, those would be implicitly rendered for their respective action.

### View path class mappings

Not all component libraries are integrated into Rails views, so you might have to manually configure the view paths in your Rails application. This instructs the Rails code reloader, Zeitwerk, to load the components.

```ruby
# ./config/application.rb
module MyApp
  class Application < Rails::Application
    config.autoload_paths << "#{root}/app/views"
    config.autoload_paths << "#{root}/app/views/layouts"
    config.autoload_paths << "#{root}/app/views/components"
    # Your code
  end
end
```

For example, the `Show` component in the `Posts` module would be loaded from `./app/views/posts/show.rb` and the `Layout` component in the `Layouts` module would be loaded from `./app/views/layouts/layout.rb`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/superview. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rubymonolith/superview/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Superview project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rubymonolith/superview/blob/main/CODE_OF_CONDUCT.md).
