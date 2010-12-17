module ServiceCrud

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def model(klass=nil)
      @model ||= klass
      @model || self.to_s.gsub("Controller", "").singularize.constantize
    end

    def model_attribute_root(root=nil)
      @model_attribute_root ||= root
      @model_attribute_root || self.model.to_s.underscore.to_sym
    end

    def orm_methods!(orm_module)
      self.orm_methods.extend orm_module
    end

    def orm_methods
      @orm_methods ||= ServiceCrud::DefaultOrm.new
    end
    
    def before_create(method=nil, &block)
      self.before_creates << method if method
      self.before_creates << block if block 
    end
   
    def before_update(method=nil, &block)
      self.before_updates << method if method
      self.before_updates << block if block 
    end

    def before_destroy(method=nil, &block)
      self.before_destroys << method if method
      self.before_destroys << block if block 
    end

    def after_create(method=nil, &block)
      self.after_creates << method if method
      self.after_creates << block if block 
    end
    
    def after_update(method=nil, &block)
      self.after_updates << method if method
      self.after_updates << block if block 
    end

    def after_destroy(method=nil, &block)
      self.after_destroys << method if method
      self.after_destroys << block if block 
    end

    def before_creates;   @before_creates  ||= []; end 
    def before_updates;   @before_updates  ||= []; end
    def before_destroys;  @before_destroys ||= []; end
    def after_creates;    @after_creates   ||= []; end 
    def after_updates;    @after_updates   ||= []; end
    def after_destroys;   @after_destroys  ||= []; end
 
  end

  # GET /your_model.xml
  # GET /your_model.json
  def index
    @models = self.class.model.send self.class.orm_methods.all

    respond_to do |format|
      format.xml  { render :xml => @models }
      format.json { render :json => @models }
    end
  end

  # GET /your_model/1.xml
  # GET /your_model/1.json
  def show
    @model = self.class.model.send self.class.orm_methods.find, params[:id] 

    respond_to do |format|
      format.xml  do 
        render :status => 404, :text => "" and return unless @model
        render :xml => @model
      end
      format.json do 
        render :status => 404, :text => "" and return unless @model
        render :json => @model
      end
    end
  end

  # POST /your_model.xml
  # POST /your_model.json
  def create
    @model = self.class.model.send self.class.orm_methods.new, params[self.class.model_attribute_root] 
    run_service_crud_before_callbacks @model

    respond_to do |format|
      if @model.send self.class.orm_methods.save
        run_service_crud_after_callbacks @model
        location = "/#{controller_name}/#{@model.id}"
        format.xml  { render :xml => @model, :status => :created, :location => location }
        format.json { render :json => @model, :status => :created, :location => location }
      else
        format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
        format.json { render :json => {:errors => @model.errors.to_a}.to_json, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /your_model/1.xml
  # PUT /your_model/1.json
  def update
    @model = self.class.model.send self.class.orm_methods.find, params[:id] 
    run_service_crud_before_callbacks @model

    respond_to do |format|
      if @model.send self.class.orm_methods.update_attributes, params[self.class.model_attribute_root]
        run_service_crud_after_callbacks @model
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.xml  { render :xml  => @model.errors, :status => :unprocessable_entity }
        format.json { render :json => {:errors => @model.errors.to_a}.to_json, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /your_model/1.xml
  # DELETE /your_model/1.json
  def destroy
    @model = self.class.model.send self.class.orm_methods.find, params[:id]
    run_service_crud_before_callbacks @model
    @model.send self.class.orm_methods.destroy
    run_service_crud_after_callbacks @model
 
    respond_to do |format|
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  private
  def run_service_crud_before_callbacks(model)
    run_service_crud_callbacks self.class.send("before_#{action_name}s".to_sym), model
  end

  def run_service_crud_after_callbacks(model)
    run_service_crud_callbacks self.class.send("after_#{action_name}s".to_sym), model
  end

  def run_service_crud_callbacks(service_crud_callbacks, model)
    service_crud_callbacks.each do |method|
      method.call(model) if method.respond_to?(:call) # if it's a proc
      self.send method, model if method.kind_of?(Symbol)
    end
  end
end
