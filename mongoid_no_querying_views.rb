module Mongoid #:nodoc:
  module Contexts #:nodoc:
    class Mongo
      begin
        alias :orig_execute :execute
        def execute(paginating = false)
          first_view   = caller.grep(/app\/views/).first
          first_helper = caller.grep(/app\/helpers/).first

          # if we're coming from a view, let's analyze the situation
          if !first_view.nil? and (first_helper.nil? or (caller.index(first_view) < caller.index(first_helper)))
            raise "No query from view prohibited, eager-load from a controller instead."
          else
            orig_execute(paginating)
          end
        end
      rescue
        # the adapter has not been instantiated
      end
    end
  end
end
