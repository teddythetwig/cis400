class ServersController < ApplicationController
  before_filter :authenticate_user!, :match_user_server
  before_filter :make_connection, :only=>:query
  

  
  def index
    @servers = Server.where(:user_id => @user)
  end

  def destroy
    @server = Server.find(params[:id])
    @server.destroy
    redirect_to user_servers_path(@user)
  end

  def new
    @server = Server.new
  end

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
    @server = Server.find(params[:id])
    @status = @server.check_status
    if @status != "available"
      flash[:notice] = "Server Status is: #{@status} Server is not available yet, please try again later"
      redirect_to user_servers_path(@user)
    end
  end
  
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
  
  def match_user_server
    @user = User.find(params[:user_id])
    @server = Server.find(params[:id]) if params[:id]
    #Users can only access their own resources
    if !(current_user.id == @user.id and (@server.nil? or current_user.servers.include? @server))
      redirect_to :root
    end
  end
  
  def make_connection
    @server = Server.find(params[:server_id])
    #Virtural attribute of user that is created on sign-in and destroyed on sign-out
    @server.make_connection
    #@server.sql ||= Mysql2::Client.new(:host => "#{@server.url}", :username => "username#{@server.user_id}", :password => "cis400", :port => 3306)
  end
  
end
