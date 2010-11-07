class Book < CouchRest::Model::Base
  use_database BOOK_DB
  property :title
  property :updated_by
  validates_presence_of :title
end
