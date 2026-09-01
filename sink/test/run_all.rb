# frozen_string_literal: true

require_relative 'test_helper'
Dir.glob(File.join(__dir__, '*_test.rb')).sort.each { |f| require f }
