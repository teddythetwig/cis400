class InstancesController < ApplicationController
  before_filter :authenticate_user! , :current_user_and_server
  before_filter :is_owned, :only =>[:edit, :new, :query, :update ]
  before_filter :make_connection, :only => [:query, :update]
  def index
    @instances = @server.instances 
  end
  
  def new
    @instance = Instance.new
  end
  
  def create
    begin
      @instance = Instance.new(params[:instance])
      @instance.server = @server
      @instance.save
      redirect_to edit_user_server_instance_path(@user,@server,@instance)
    rescue
      flash[:notice] = "Database with name #{@instance.name} already exists, please try again"
      redirect_to user_server_instances_path(@user,@server)
    end
  end
  
  def edit
    @instance = Instance.find(params[:id])
  end
  
  def update
    @instance = Instance.find(params[:id])
    logger.info(params[:json])
    @instance.db_json = params[:json]
    query = params[:query].gsub(/(\n|\t|\r)/, ' ').gsub(/>\s*</, '><').squeeze(' ').split("\;")
    query.reject!(&:blank?)
    logger.info("Parsed query: #{query.each{|t| puts t}}")
    @results = []
    query.each{|q| @results << @server.sql.query(q)}
    #@results = @server.sql.query(params[:query])
    #logger.debug "Results: #{@results.size} from connection #{@server.sql}"
    logger.info @results.to_json
    @instance.save
    respond_to do |format|
      format.json{render :json => @results.to_json}
      format.html
    end
  end
  
  #this should only be reached with json
  def query
    query = params[:query].gsub(/(\n|\t|\r)/, ' ').gsub(/>\s*</, '><').squeeze(' ').split("\;")
    query.reject!(&:blank?)
    logger.info("Parsed query: #{query.each{|t| puts t}}")
    @results = []
    query.each{|q| @results << @server.sql.query(q)}
    #@results = @server.sql.query(params[:query])
    #logger.debug "Results: #{@results.size} from connection #{@server.sql}"
    logger.info @results.to_json
    respond_to do |format|
      format.json{render :json => @results.to_json}
      format.html
    end
  end
  
  def make_connection
    @server.make_connection Instance.find(params[:id]).name
  end
  
  def current_user_and_server
    @user = current_user
    @server = @user.server
  end
  
  def is_owned
    @instance = Instance.find(params[:id])
    if @instance.server.user != current_user
      redirect_to :root
    end
  end

  
end
