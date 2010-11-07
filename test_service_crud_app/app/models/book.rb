class Book < CouchRest::Model::Base
  use_database BOOK_DB
  property :title
  validates_presence_of :title
end
