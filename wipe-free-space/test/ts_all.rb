require 'minitest/unit'
require "minitest/reporters"

require_relative 'app_test'

MiniTest::Reporters.use!

MiniTest::Unit.autorun
