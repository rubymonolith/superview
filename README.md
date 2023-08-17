# Superview

Build Rails applications, from the ground up, using [Phlex](https://www.phlex.fun/) components, like this.

```ruby
class PostsController < ApplicationController
  include Superview::Actions

  before_action :load_post

  class Show < ApplicationComponent
    attr_accessor :post

    def template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

  private
    def load_post
      @post = Post.find(params[:id])
    end
end
```

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add superview

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install superview

## Usage

Install `phlex-rails` in your Rails application.

    $ bin/rails generate phlex:install

Then add `include Superview::Actions` to any controllers you'd like to render Phlex components.

```ruby
class PostsController < ApplicationController
  include Superview::Actions

  before_action :load_post

  class Show < ApplicationComponent
    attr_accessor :post

    def template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

  private
    def load_post
      @post = Post.find(params[:id])
    end
end
```

The `Show` class will render when the `PostsController#show` action is called. To use along side other formats or render manually, you can define the `PostsController#show` as you'd expect:

```ruby
class PostsController < ApplicationController
  include Superview::Actions

  before_action :load_post

  class Show < ApplicationComponent
    attr_accessor :post

    def template(&)
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/superview. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rubymonolith/superview/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Superview project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rubymonolith/superview/blob/main/CODE_OF_CONDUCT.md).
