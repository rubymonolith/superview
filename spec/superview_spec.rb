require "rails_helper"

# Define a test controller
class PostsController < ActionController::Base
  include Superview::Actions

  before_action :load_post

  class Show < Phlex::HTML
    attr_writer :post

    def view_template
      h1 { @post.title }
      div(class: "prose") { @post.body }
    end
  end

  class New < Phlex::HTML
    def view_template
      raise "Should never hit this"
    end
  end

  class Edit < ViewComponent::Base
    attr_writer :post

    def call
      <<~HTML
        h1 { "Edit #{@post.title}" }
        div(class: "prose") { "#{@post.body}" }
      HTML
    end
  end

  def new
    render inline: "Don't hit new"
  end

  def a_class
    render phlex Show
  end

  def an_instance
    render phlex Show.new
  end

  def a_string
    render phlex "show"
  end

  def a_symbol
    render phlex :show
  end

  private

  def load_post
    @post = OpenStruct.new(title: "Test Post", body: "This is a test body.")
  end
end

RSpec.describe PostsController, type: :controller do
  # Define routes for testing
  before do
    Rails.application.routes.draw do
      get "posts/show", to: "posts#show"
      get "posts/new", to: "posts#new"
      get "posts/edit", to: "posts#edit"
      get "posts/a_class", to: "posts#a_class"
      get "posts/an_instance", to: "posts#an_instance"
      get "posts/a_string", to: "posts#a_string"
      get "posts/a_symbol", to: "posts#a_symbol"
    end
  end

  after do
    Rails.application.routes_reloader.reload!
  end

  # Test the action
  describe "GET #show" do
    it "renders the Phlex view for the action" do
      get :show
      expect(response.body).to include("Test Post")
      expect(response.body).to include("This is a test body.")
    end
  end

  describe "GET #new" do
    it "renders the action" do
      get :new
      expect(response.body).to include("Don't hit new")
    end
  end

  describe "GET #edit" do
    it "renders the Phlex view for the action" do
      get :edit
      expect(response.body).to include("Edit Test Post")
      expect(response.body).to include("This is a test body.")
    end
  end

  describe "GET #a_class" do
    it "renders the Phlex view for the action" do
      get :a_class
      expect(response.body).to include("Test Post")
    end
  end

  describe "GET #an_instance" do
    it "renders the Phlex view for the action" do
      get :an_instance
      expect(response.body).to include("Test Post")
    end
  end

  describe "GET #a_string" do
    it "renders the Phlex view for the action" do
      get :a_string
      expect(response.body).to include("Test Post")
    end
  end

  describe "GET #a_symbol" do
    it "renders the Phlex view for the action" do
      get :a_symbol
      expect(response.body).to include("Test Post")
    end
  end
end
