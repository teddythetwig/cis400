class Server < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # These two callbacks ensure that the application server is syncronized with the RDS server in terms
  # of server existence
  after_create do |s|
    #initialize db on the rds servers
    #change this from hardcoding the password, on the first time it should set it
    $RDS.create_db_instance(:db_instance_identifier => "#{name}", :allocated_storage => 5,:db_instance_class => "db.t1.micro",:engine => "MySQL",:master_username=>"username#{user}",:master_user_password=>"cis400")
    #check if connection is valid, if not, return error and cause transaction rollback
  end
  
  after_destroy do |s|
    $RDS.delete_db_instance(:db_instance_identifier => "#{name}", :skip_final_snapshot => true)
  end

  before_save do |s|
    self[:db_json] ||= ("{\"tables\":[]}")
  end
  # Retrieves the server status from RDS server
  def check_status
    response = $RDS.describe_db_instances(:db_instance_identifier => "#{name}")
    response = response[:db_instances].first[:db_instance_status]
  end
  
  
  # Json values are stored in the database as a string, these methods allow working 
  # with json as an object without the intermediate step of conversion
  def db_json
    ActiveSupport::JSON.decode(self[:db_json])
  end
  
  def db_json=(value)
    self[:db_json] = ActiveSupport::JSON.encode(value)
  end

end
