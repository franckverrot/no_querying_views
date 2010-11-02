No Querying View
================

This Rails plugin will tell you when you and your folks are querying the
database from something else than a controller and a model.

Context
-------

Rails is a MVC framework. The separation of concern should be respected
to prevent bad things to happen in your application.

Example: An order has N order lines. Each of these order lines has 1
related item, and each of these items belongs to 1 category.

In Ruby code, your models would look like this:

#####app/models/order.rb
    class Order < AR::Base
      has_many :lines
    end


#####app/models/line.rb
    class Line < AR::Base
      has_one :item
    end


#####app/models/item.rb
    class Item < AR::Base
      belongs_to :category
    end


Say now you want to display them onto a single page, here's your
naive version of cart_controller.rb:

#####app/controllers/cart_controller.rb
    class CartController < AC::Base
      def show
        @cart = Cart.find(params[:id])
      end
    end

And a version of the views used to display the result:

#####app/views/cart/show.html.haml
    %h1
      = @cart.title
    %h2
      %span Items
      %ul
        = render :partial => 'item', :collection => cart.items (1)

#####app/views/cart/show.html.haml
    %li
      %span
        = item.title
      %div{:class => 'item_description}
        = item.description
        = item.category (2)

The problem
-----------

If you use a tool that generates execution traces (like New Relic RPM),
you will see that - for 1 cart, 40 items, 20 categories - you will
execute 1 * 40 * 40 = 161 queries against the database!

This is called the N + 1 problem [http://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations] and it can be solved by the eager-loading strategy.

######## OH: "Yeah but my DB is so small and so fast that I don't even see that"

This is true if you are alone on the website. But Rails will also have
troubles generating the page (HAML, ERB, whatever) and New Relic won't
even tell you that the querie are slowing down the application: the
queries are fast as hell.

What is slowing down the application is the combination of the
rendering and the querying:
  1. Rendering partials is slower than inline code
  2. Executing a query costs time (retrieving the DB connection within
     the pool, executing and fetching the results, ...): the resources
     are not being used for free on your machine.

The solution
------------

Silver bullets don't exist but most of the time you can speed up the
performance by eager-loading what you will expect in your views.

From an architectural point of view, it is **wrong** to query the DB
from a view. There are many reasons not to do so and the internet is
full of litterature about it.

Right now, here is a piece of code to help you remove any DB query from your
views.

###Rails 3.x

####Install
    cd /my/rails/3/app_root/
    wget http://github.com/cesario/no_querying_view/tree/master/no_querying_views.rb > config/initializers/no_querying_views.rb

####Uninstall
    cd /my/rails/3/app_root/
    rm config/initializers/no_querying_views.rb
