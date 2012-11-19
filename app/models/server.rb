class Server < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
