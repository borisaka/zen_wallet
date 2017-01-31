# frozen_string_literal: true
LIB_ROOT = File.expand_path(File.join("..", "..", "lib"), __FILE__)
$LOAD_PATH.unshift LIB_ROOT
require "zen_wallet"
require "minitest/autorun"
require "mocha/mini_test"
require "pry"
# require "pry-rescue/minitest" if ENV["DEBUG"]
