# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "zen_wallet"
require "minitest/autorun"
require "mocha/mini_test"
require "pry-rescue/minitest" if ENV["DEBUG"]
