ENV["RAILS_ENV"] ||= 'test'

require 'minitest/autorun'
require 'minitest/spec'

require 'rails/all'
require 'no_querying_views'
require_relative 'support/app.rb'
