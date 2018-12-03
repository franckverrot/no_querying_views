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

  module NoQueryingViews
    def self.included(base)
      base.class_eval do
        alias_method_chain :exec_query, :nqv
      end
    end

    def exec_query_with_nqv(*args)
      first_view   = caller.grep(/app\/views/).first
      first_helper = caller.grep(/app\/helpers/).first

      # if we're coming from a view, let's analyze the situation
      if first_view && (first_helper.nil? || (caller.index(first_view) < caller.index(first_helper)))
        reason = first_view || first_helper
        file, line, _ = reason.split(':')
        raise NoQueryingViewError, "Latest query located in #{file}, line #{line}"
      else
        exec_query_without_nqv(*args)
      end
    end
  end

  module ::ActiveRecord
    module ConnectionAdapters
      %w(PostgreSQLAdapter SQLite3Adapter).each do |adapter_name|
        begin
          adapter = const_get adapter_name
          adapter.send(:include, NoQueryingViews)
        rescue Exception => e
          puts "#{e.class} happened: #{e.message}"
        end
      end
    end
  end
end
