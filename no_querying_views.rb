module ::ActiveRecord
  module ConnectionAdapters
    %w(PostgreSQLAdapter MysqlAdapter SQLite3Adapter).each do |adapter_name|
      begin
        adapter = const_get adapter_name
        adapter.class_eval do
          puts "[WARNING] NoQueryingViews will prevent any PG connection to be triggered from within your views"
          alias :orig_execute :execute
          def execute(*args)
            first_view   = caller.grep(/app\/views/).first
            first_helper = caller.grep(/app\/helpers/).first

            # if we're coming from a view, let's analyze the situation
            if !first_view.nil? and (first_helper.nil? or (caller.index(first_view) < caller.index(first_helper)))
              raise "No query allowed within a view, try within a controller instead."
            else
              orig_execute *args
            end
          end
        end
      rescue
        # the adapter has not been instantiated
      end
    end
  end
end
