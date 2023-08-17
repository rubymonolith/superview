# Superview

Include in controllers to map action names to class names. This makes it possible to embed Phlex components directly into Rails controllers without having to go through other templating systems like Erb.

Instance methods will be assigned to views that have `attr_accessor` methods.

Consider a blog post controller:

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

The `@post` variable gets set in the `Show` view class via `Show#post=`.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add superview

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install superview

## Usage

Install `phlex-rails` in your application.

    $ bin/rails generate phlex:install

Then include the following any controller you'd like to render Phlex components.

```ruby
class PostsController < ApplicationController
  include Superview::Actions

  class Show < ApplicationComponent
    def template(&)
      h1 { "Hello World" }
    end
  end
end
```

The `Show` class will render when the `PostsController#show` action is called.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rubymonolith/superview. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/rubymonolith/superview/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Superview project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/rubymonolith/superview/blob/main/CODE_OF_CONDUCT.md).
