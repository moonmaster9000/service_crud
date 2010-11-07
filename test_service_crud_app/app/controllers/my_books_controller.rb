class MyBooksController < ApplicationController
  include ServiceCrud
  orm_methods! ServiceCrud::CouchRest::Model
  model Book
  model_attribute_root :my_book
  before_update :set_updated_by

  private
  def set_updated_by(model)
    model.updated_by = "test user!"
  end
end
