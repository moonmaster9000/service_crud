require 'spec_helper'


describe "Book Signups Service" do
  before do
    @book_json = {:book => {:title => "My Book Title"}}.to_json
    @book_xml  = {:title => "My Book Title"}.to_xml :root => :book
    @invalid_book_json = {:book => {:title => nil}}.to_json
    @invalid_book_xml = {:title => nil}.to_xml :root => :book
  end
  
  describe "READ" do    
    describe "READ ALL" do
      before do
        10.times { Book.create :title => "My Book Title" }
      end

      describe "GET /books.json" do
        it "return all signups in json" do
          get '/books.json'
          last_response.body.should == Book.all.to_json
        end
      end

      describe "GET /books.xml" do
        it "return all signups in xml" do
          get '/books.xml'
          last_response.body.should == Book.all.to_xml
        end
      end
    end

    describe "READ ONE" do
      before do
        @book = Book.create :title => "My Book Title" 
      end

      describe "GET /books/:id.xml" do
        it "return the requested book as xml" do
          get "/books/#{@book.id}.xml"
          last_response.body.should == Book.first.to_xml
        end

        it "return a 404 when the book is not found" do
          get "/books/jkfdlsajkfdsa.xml"
          last_response.status.should == 404
        end
      end

      describe "GET /books/:id.json" do
        it "return the requested book as json" do
          get "/books/#{@book.id}.json"
          last_response.body.should == Book.first.to_json
        end
      end
    end
  end
 
  describe "CREATE" do
    describe "POST /books.json" do
      it "create a newsletter signup from the json body" do
        post '/books.json', @book_json, "CONTENT_TYPE" => 'application/json'
        last_response.body.should == Book.all.first.to_json
      end

      it "return errors as json if the POST request was invalid" do
        post "/books.json", @invalid_book_json, "CONTENT_TYPE" => 'application/json'
        last_response.body.should == %{{"errors":["Title can't be blank"]}}
      end

      it "set the location header to the url of the newly created book" do
        post "/books.json", @book_json, "CONTENT_TYPE" => 'application/json'
        last_response.headers["Location"].include?("/books/#{Book.first.id}").should be_true
      end
    end

    describe "POST /books.xml" do
      it "create a newsletter signup from the xml body" do
        post '/books.xml', @book_xml, "CONTENT_TYPE" => 'application/xml'
        last_response.body.should == Book.all.first.to_xml
      end

      it "return errors as xml if the POST request was invalid" do
        post "/books.xml", @invalid_book_xml, "CONTENT_TYPE" => 'application/xml'
        last_response.body.split.should == (<<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <errors>
            <error>Title can't be blank</error>
          </errors>
        XML
        ).split
      end

      it "set the location header to the url of the newly created book" do
        post "/books.xml", @book_xml, "CONTENT_TYPE" => 'application/xml'
        last_response.headers["Location"].include?("/books/#{Book.first.id}").should be_true
      end
    end
  end

  describe "UPDATE" do
    before do
      @book = Book.create :title => "hi@hi.com" 
    end

    describe "PUT /books/:id.xml" do
      it "update the book with the provided xml" do  
        put "/books/#{@book.id}.xml", @book_xml, "CONTENT_TYPE" => 'application/xml'
        Book.first.title.should == "My Book Title"
      end
      
      it "return errors as xml if the PUT request was invalid" do
        put "/books/#{@book.id}.xml", @invalid_book_xml, "CONTENT_TYPE" => 'application/xml'
        last_response.body.split.should == (<<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <errors>
            <error>Title can't be blank</error>
          </errors>
        XML
        ).split
      end
    end
    
    describe "PUT /books/:id.json" do
      it "update the book with the provided json" do  
        put "/books/#{@book.id}.json", @book_json, "CONTENT_TYPE" => 'application/json'
        Book.first.title.should == "My Book Title"
      end
      
      it "return errors as json if the PUT request was invalid" do
        put "/books/#{@book.id}.json", @invalid_book_json, "CONTENT_TYPE" => 'application/json'
        last_response.body.should == %{{"errors":["Title can't be blank"]}}
      end
    end
  end
  
  describe "DELETE" do
    before do
      @book = Book.create :title => "hi@hi.com" 
    end

    describe "DELETE /books/:id.xml" do
      it "update the book with the provided xml" do  
        Book.all.count.should == 1
        delete "/books/#{@book.id}.xml"
        Book.all.count.should == 0
      end
    end
    
    describe "DELETE /books/:id.json" do
      it "update the book with the provided json" do  
        Book.all.count.should == 1
        delete "/books/#{@book.id}.json"
        Book.all.count.should == 0
      end
    end
  end


end
