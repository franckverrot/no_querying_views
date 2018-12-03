# No Querying Views

This gem will tell you when your team when they are querying the
database from a view.

It currently supports SQLite3 and PostgreSQL.


## Requirements

* Rails 5.x

## INSTALL

Manually, you can install the gem:

    gem install no_querying_views

In your gemspec:

    gem 'no_querying_views', '~> 2.0.0'


## Context

Rails is a MVC framework. The separation of concern should be respected
to prevent bad things to happen in your application.

Example: An order has N order lines. Each of these order lines has 1
related item, and each of these items belongs to 1 category.

In Ruby code, your models would look like this:

```ruby
# app/models/order.rb
class Order < ActiveRecord::Base
  has_many :lines
end


# app/models/line.rb
class Line < ActiveRecord::Base
  has_one :item
end


# app/models/item.rb
class Item < ActiveRecord::Base
  belongs_to :category
end


# app/models/category.rb
class Category < ActiveRecord::Base
end
```

Now, if you want to display them on a single page, here is a naive version of
order_controller.rb:

```ruby
# app/controllers/order_controller.rb
class OrderController < ApplicationController
  def show
    @order = Order.find(params[:id])  # 1 query
  end
end
```

And a naive version of the views used to display the result:

```ruby
# app/views/orders/show.html.haml
%h1
  = @order.title
%h2
  %span Items
  %ul
    = render :partial => 'lines', :collection => order.lines   # 1 query, so far: 2 queries

# app/views/orders/_lines.html.haml executed for **each single line**
%li
  %span
    = line.item.title          # 1 query
    = line.price
  %div{:class => 'item_description'}
    = line.item.description    # 0 query (cached)
    = line.item.category       # 1 query
```

## The problem

If you use a tool that generates execution traces (like NewRelic RPM),
you will see that - for 1 order, 40 lines, 30 items, 20 categories - you will
execute:
   1 (select * from order)
+  1 (select * from lines inner join ... where order_id = foo)
+ 40 (select * from items inner join ... where line.item_id = bar)
+ 40 (select * from categories inner join ... where item.category_id = baz)
 ----
  82 queries against the database!

This is called the [N + 1 problem](http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations) and it can be solved by an eager-loading strategy.

######## OH: "Yeah, but my database is so small and so fast that I don't even see that!"

This is true if you are the only user of the website.  But Rails will also have
troubles generating the page (HAML, ERB, whatever) and NewRelic won't tell you
that the queries are slowing down the application: the queries are fast as
hell.

The combination of the rendering and the querying is slowing down the application, because:

  1. Rendering a partial is slower than inline code
  2. Executing a query costs time (retrieving the DB connection within
     the pool, executing and fetching the results, ...): the resources
     are not being used for free on your machine.

## The solution

Silver bullets don't exist, but most of the time you can speed up the
performance by eager-loading the data you expect in your views.

From an architectural point of view, it is **wrong** to query the DB
from a view. There are many reasons not to do so and the internet is
full of literature about it.

Right now, here is a piece of code to help you remove any DB query from your
views.

## What does this code do?

It will raise an exception everytime you and your people try to query the
database from within a view.

It only overrides the ``execute`` method of the adapter and checks the
call stack.

## License

MIT License. Copyright 2014 - Franck Verrot <franck@verrot.fr>
