class ServersController < ApplicationController
  before_filter :authenticate_user!,:current_user_and_server
  before_filter :make_connection, :only=>:query
  

  
  def index

  end

  def destroy
    @server.destroy
    redirect_to user_servers_path(@user)
  end

  def new
    @server = Server.new
  end

  #this method is deprecated, server creation is done when user is created
  def create
    @server = Server.new(params[:server])
    @server.user = @user
    #handle in case there is a duplicate server on aws 
    begin
      if @server.save! 
        redirect_to user_servers_path
      else
        flash[:notice]= @server.error.to_s
        redirect_to new_user_server_path(@user)
      end
    rescue => error
      flash[:notice] = error.to_s
      redirect_to new_user_server_path(@user)
    end
      
  end

  def show
    @status = @server.check_status
    if @status != "available"
      flash[:notice] = "Server Status is: #{@status} Server is not available yet, please try again later"
      redirect_to user_path(@user)
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
  
  def current_user_and_server
    @user = current_user
    @server = @user.server
  end
  
  def make_connection
    #Virtural attribute of user that is created on sign-in and destroyed on sign-out
    @server.make_connection
    #@server.sql ||= Mysql2::Client.new(:host => "#{@server.url}", :username => "username#{@server.user_id}", :password => "cis400", :port => 3306)
  end
  
end
