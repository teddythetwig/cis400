class Server < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  after_create do |s|
    #initialize db on the rds servers
    #change this from hardcoding the password, on the first time it should set it
    $RDS.create_db_instance(:db_instance_identifier => "#{name}", :allocated_storage => 5,:db_instance_class => "db.t1.micro",:engine => "MySQL",:master_username=>"username#{user}",:master_user_password=>"cis400")
    #check if connection is valid, if not, return error and cause transaction rollback
  end
  
  after_destroy do |s|
    $RDS.delete_db_instance(:db_instance_identifier => "#{name}", :skip_final_snapshot => true)
  end
  
  def check_status
    response = $RDS.describe_db_instances(:db_instance_identifier => "#{name}")
    return response[:db_instances].first[:db_instance_status]
  end

end
