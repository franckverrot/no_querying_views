require 'rails/test_help'

module NoQueryingViews
  class Application < ::Rails::Application
    config.secret_key_base = 'x' * 30
    config.paths['app/views'].unshift("#{Rails.root}/test/app/views")
    config.eager_load = false
  end
end
Rails.logger = Logger.new('/dev/null')

class MyModel < ActiveRecord::Base
  self.primary_key = "id"
end

class FooController < ActionController::Base
  def querying; end
  def non_querying; end
end

ENV['DATABASE_URL'] = 'sqlite3:test/fixtures/foo.sqlite3'

Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true

Rails.application.initialize!
