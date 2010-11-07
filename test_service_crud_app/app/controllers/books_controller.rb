class BooksController < ApplicationController
  include ServiceCrud
  orm_methods! ServiceCrud::CouchRest::Model
end
