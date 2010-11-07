# Service Crud

The `service_crud` gem: A simple mixin for adding crud actions for a RESTful, ActiveResource style service (xml and json).

## Requirements

This gem works with Rails 3.

## Installation

    $ cd /path/to/your/rails3/app
    $ echo "gem service_crud" >> Gemfile
    $ bundle install

## Usage

Let's suppose we have a "Book" model, and we want to create XML and JSON RESTful services for it. Simple: 

First, go to your routes.rb file and add the following route:
  
    resources :books

Next, create the following controller in RAILS_ROOT/app/books_controller.rb:

    class BooksController
      include ServiceCrud
    end

That's it. You can now GET, POST, PUT, and DELETE books through the standard RESTful urls.

## Callbacks

Sometimes you need to do a little extra work on your data before/after you create/update/destroy. And sometimes that can't be pushed down to the ORM layer. 
For example, suppose we want to set the `:updated_by` property on our model to the `current_user`. We could simply: 

    class BooksController
      include ServiceCrud
      before_update :set_updated_by

      private
      def set_updated_by(model)
        model.update_by = current_user
      end
    end

ServiceCrud supports the following callbacks: `before_create`, `after_create`, `before_update`, `after_update`, `before_destroy`, and `after_destroy`. 

## Model Guessing

The `service_crud` library will look at the controller name and try to guess the model (e.g., "BooksController" -> "Book").

If your controller name doesn't match your model, call the `model` method:

    class MyBooksController
      include ServiceCrud
      model Book
    end

## PUT/POST parameter guessing

Similarly, on POST or PUT, `service_crud` assumes that the top-level node of the XML or JSON is the lowercased, underscored, singularized symbol of your model name. 

If that's not the case for your service, call the `model_attribute_root` class method: 

    class BooksController
      include ServiceCrud
      model_attribute_root :my_book
    end

## ORM

The `service_crud` library assumes an ActiveRecord ORM by default. It also, out of the box, supports the `couchrest_model` ORM for couchdb. 
To use `couchrest_model`, simply:

    class BooksController
      include ServiceCrud
      orm_methods! ServiceCrud::CouchRest::Model
    end

The default ORM methods are:
    
    module ServiceCrud
      module DefaultOrm
        def all; :all; end
        def new; :new; end
        def find; :find; end
        def destroy; :destroy; end
        def update_attributes; :update_attributes; end
        def save; :save; end
      end
    end

If you're using an ORM other than ActiveRecord or CouchRest::Model, and some or all of your ORM's method names differ from ActiveRecord's,
then simply create a module that redefines one or more DefaultOrm methods. For example, suppose we create our own ORM, `MoonOrm`, and our method for finding 
records is `lookup` instead of `find`. Then we'd simply:

    module MoonOrmMethods
      def find; :lookup; end
    end

Then, in our controller:
    
    class BooksController
      include ServiceCrud
      orm_methods! MoonOrmMethods
    end
