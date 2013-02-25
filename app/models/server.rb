class Server < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name, :user
  validates_uniqueness_of :name
  
  # These two callbacks ensure that the application server is syncronized with the RDS server in terms
  # of server existence
  after_create do |s|
    #initialize db on the rds servers
    #change this from hardcoding the password, on the first time it should set it
    #should also hash username or something to prevent info leak
    $RDS.create_db_instance(:db_instance_identifier => "#{name}", :allocated_storage => 5,:db_instance_class => "db.t1.micro",:engine => "MySQL",:master_username=>"username#{user.id}",:master_user_password=>"cis400")
    #check if connection is valid, if not, return error and cause transaction rollback
  end
  
  after_destroy do |s|
    $RDS.delete_db_instance(:db_instance_identifier => "#{name}", :skip_final_snapshot => true)
  end
  #Have to do this because some empty json bug
  before_save do |s|
    self[:db_json] ||= ("{\"tables\":[]}")
  end
  # Retrieves the server status from RDS server
  # ENUMERATE POSSIBLE RESPONSES
  def check_status
    response = $RDS.describe_db_instances(:db_instance_identifier => "#{name}")
    status = response[:db_instances].first[:db_instance_status]
    if status == "available"
      self.url = response[:db_instances].first[:endpoint][:address]
      self.save
    end
    return status
  end
  
  attr_accessor :sql
 
  
  # Json values are stored in the database as a string, these methods allow working 
  # with json as an object without the intermediate step of conversion
  def db_json
    ActiveSupport::JSON.decode(self[:db_json])
  end
  
  def db_json=(value)
    self[:db_json] = ActiveSupport::JSON.encode(value)
  end
  
  # Executes query on remote server
  def make_connection
    self.sql ||= Mysql2::Client.new(:host => "#{self.url}", :username => "username#{self.user_id}", :password => "cis400", :port => 3306, :database => "helloworld")
  end

end
