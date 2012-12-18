class Server < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  before_create do |s|
    #initialize db on the rds servers
    $RDS.create_db_instance(:db_instance_identifier => "#{name}", :allocated_storage => 5,:db_instance_class => "db.t1.micro",:engine => "MySQL",:master_username=>"username#{user}",:master_user_password=>"cis400")
    #check if connection is valid, if not, return error and cause transaction rollback
  end
end
