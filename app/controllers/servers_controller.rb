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
    @server = Server.new(params[:server],:user => @user)
    @server.save
    redirect_to user_servers_path
  end

  def show
    @server = Server.find(params[:id])
  end
  
  def get_user
    @user = User.find(params[:user_id])
  end
end
