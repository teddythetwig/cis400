class UsersController < ApplicationController
  before_filter :authenticate_user!
  def show
    @user = current_user
  end

  def index
    
  end

  def destroy
  end

  def new
  end

  def create
  end

  def update
  end

  def edit
  end
  
  
end
