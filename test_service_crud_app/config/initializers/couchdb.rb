COUCH_SERVER = CouchRest::Server.new "http://admin:password@localhost:5984"
BOOK_DB = COUCH_SERVER.database! "book_#{Rails.env}_db"
