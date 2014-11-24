def safe_require(path)
  begin
    require path
  rescue Gem::LoadError => e
    "Not loading #{path}: #{e.message}"
  end
end

if !Rails.env.production?
  puts "[WARNING] NoQueryingViews is enabled. It is preventing your views from triggering PG or SQLite3 database connections."

  safe_require 'active_record/connection_adapters/sqlite3_adapter.rb'
  safe_require 'active_record/connection_adapters/postgresql_adapter.rb'

  NoQueryingViewError = Class.new(Exception)

  module ::ActiveRecord
    module ConnectionAdapters
      %w(PostgreSQLAdapter SQLite3Adapter).each do |adapter_name|
        begin
          adapter = const_get adapter_name
          adapter.class_eval do
            def exec_query(*args)
              first_view   = caller.grep(/app\/views/).first
              first_helper = caller.grep(/app\/helpers/).first

              # if we're coming from a view, let's analyze the situation
              if !first_view.nil? and (first_helper.nil? or (caller.index(first_view) < caller.index(first_helper)))
                reason = first_view || first_helper
                file, line, _ = reason.split(':')
                raise NoQueryingViewError.new("Latest query located in #{file}, line #{line}")
              else
                super
              end
            end
          end
        rescue Exception => e
          puts "#{e.class} happened: #{e.message}"
        end
      end
    end
  end
end
