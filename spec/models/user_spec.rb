require 'spec_helper.rb'

describe User do
 
  it "should create user with original email and password" do 
    user = User.new(:email =>"testuser@gmail.com", :password => "123456")
    
    expect(user.valid?).to eq(true)
  end
  
  it "should reject user without email" do
    user = User.new(:password => "123456")
    user.valid?
    expect(user.errors_on(:email)).to eq("can't be blank")
  end
  
  it "should reject user without password" do 
    user = User.new(:email =>"testuser@gmail.com")
    user.valid?
    expect(user.errors_on(:password)).to eq("can't be blank")
  end
  
end
