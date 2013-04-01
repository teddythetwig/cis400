require 'factory_girl'

FactoryGirl.define do 
  factory :user do
    email "testuser@gmail.com"
    password "123456"
    password_confirmation "123456"
  end
end
