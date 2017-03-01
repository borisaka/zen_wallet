# frozen_string_literal: true
require "simplecov"
SimpleCov.start do
  add_filter "/test/"
end
LIB_ROOT = File.expand_path(File.join("..", "..", "lib"), __FILE__)
$LOAD_PATH.unshift LIB_ROOT
require "dry-container"
require "minitest/autorun"
require "mocha/mini_test"
require "minitest/pride"
require "pry-byebug"
require "pry"
require "btcruby"
require "zen_wallet/hd/models"
require "minitest/benchmark"
