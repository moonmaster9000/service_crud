require 'spec_helper'


describe "My Books Service" do
  before do
    @book_json = {:my_book => {:title => "My Book Title"}}.to_json
    @book_xml  = {:title => "My Book Title"}.to_xml :root => :my_book
    @invalid_book_json = {:my_book => {:title => nil}}.to_json
    @invalid_book_xml = {:title => nil}.to_xml :root => :my_book
  end
  
  describe "READ" do    
    describe "READ ALL" do
      before do
        10.times { Book.create :title => "My Book Title" }
      end

      describe "GET /my_books.json" do
        it "return all signups in json" do
          get '/my_books.json'
          response.body.should == Book.all.to_json
        end
      end

      describe "GET /my_books.xml" do
        it "return all signups in xml" do
          get '/my_books.xml'
          response.body.should == Book.all.to_xml
        end
      end
    end

    describe "READ ONE" do
      before do
        @book = Book.create :title => "My Book Title" 
      end

      describe "GET /my_books/:id.json" do
        it "return the requested book as json" do
          get "/my_books/#{@book.id}.xml"
          response.body.should == Book.first.to_xml
        end
      end

      describe "GET /my_books/:id.json" do
        it "return the requested book as json" do
          get "/my_books/#{@book.id}.json"
          response.body.should == Book.first.to_json
        end
      end
    end
  end
 
  describe "CREATE" do
    describe "POST /my_books.json" do
      it "create a newsletter signup from the json body" do
        post '/my_books.json', @book_json, "CONTENT_TYPE" => 'application/json'
        response.body.should == Book.all.first.to_json
        Book.first.updated_by.should be_nil
      end

      it "return errors as json if the POST request was invalid" do
        post "/my_books.json", @invalid_book_json, "CONTENT_TYPE" => 'application/json'
        response.body.should == %{{"errors":["Title can't be blank"]}}
      end

      it "set the location header to the url of the newly created book" do
        post "/my_books.json", @book_json, "CONTENT_TYPE" => 'application/json'
        puts "response.headers = #{response.headers.inspect}"
        response.headers["Location"].include?("/my_books/#{Book.first.id}").should be_true

      end
    end

    describe "POST /my_books.xml" do
      it "create a newsletter signup from the xml body" do
        post '/my_books.xml', @book_xml, "CONTENT_TYPE" => 'application/xml'
        response.body.should == Book.all.first.to_xml
      end

      it "return errors as xml if the POST request was invalid" do
        post "/my_books.xml", @invalid_book_xml, "CONTENT_TYPE" => 'application/xml'
        response.body.split.should == (<<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <errors>
            <error>Title can't be blank</error>
          </errors>
        XML
        ).split
      end

      it "set the location header to the url of the newly created book" do
        post "/my_books.xml", @book_xml, "CONTENT_TYPE" => 'application/xml'
        puts "response.headers = #{response.headers.inspect}"
        response.headers["Location"].include?("/my_books/#{Book.first.id}").should be_true
      end
    end
  end

  describe "UPDATE" do
    before do
      @book = Book.create :title => "hi@hi.com" 
    end

    describe "PUT /my_books/:id.xml" do
      it "update the book with the provided xml" do  
        put "/my_books/#{@book.id}.xml", @book_xml, "CONTENT_TYPE" => 'application/xml'
        Book.first.title.should == "My Book Title"
      end
      
      it "return errors as xml if the PUT request was invalid" do
        put "/my_books/#{@book.id}.xml", @invalid_book_xml, "CONTENT_TYPE" => 'application/xml'
        response.body.split.should == (<<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <errors>
            <error>Title can't be blank</error>
          </errors>
        XML
        ).split
      end
    end
    
    describe "PUT /my_books/:id.json" do
      it "update the book with the provided json" do  
        put "/my_books/#{@book.id}.json", @book_json, "CONTENT_TYPE" => 'application/json'
        Book.first.title.should == "My Book Title"
        Book.first.updated_by.should == "test user!"
      end
      
      it "return errors as json if the PUT request was invalid" do
        put "/my_books/#{@book.id}.json", @invalid_book_json, "CONTENT_TYPE" => 'application/json'
        response.body.should == %{{"errors":["Title can't be blank"]}}
      end
    end
  end
  
  describe "DELETE" do
    before do
      @book = Book.create :title => "hi@hi.com" 
    end

    describe "DELETE /my_books/:id.xml" do
      it "update the book with the provided xml" do  
        Book.all.count.should == 1
        delete "/my_books/#{@book.id}.xml"
        Book.all.count.should == 0
      end
    end
    
    describe "DELETE /my_books/:id.json" do
      it "update the book with the provided json" do  
        Book.all.count.should == 1
        delete "/my_books/#{@book.id}.json"
        Book.all.count.should == 0
      end
    end
  end


end
