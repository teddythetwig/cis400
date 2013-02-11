class ServersController < ApplicationController
  before_filter :authenticate_user!, :get_user
  def index
    @servers = Server.all
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
    @server = Server.new(params[:server],:user_id => @user.id)
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
      flash[:notice] = "Server is not available yet, please try again later"
      redirect_to user_servers_path(@user)
    end
  end
  
  def get_user
    @user = User.find(params[:user_id])
  end
end
