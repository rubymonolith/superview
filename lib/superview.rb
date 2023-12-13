# frozen_string_literal: true

require_relative "superview/version"
require "active_support/concern"
require "zeitwerk"

module Superview
  Loader = Zeitwerk::Loader.for_gem.tap do |loader|
    loader.ignore "#{__dir__}/generators"
    loader.setup
  end

  class Error < StandardError; end
end
