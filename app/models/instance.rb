class Instance < ActiveRecord::Base
  attr_accessible :name, :server_id
  belongs_to :server
  
  before_save do
    logger.debug("creating new database at #{Time.now}")
    self.server.make_connection
    self.server.sql.query("CREATE DATABASE #{self.name}")
  end
  
  after_destroy do
    self.server.make_connection
    self.server.sql.query("DROP DATABASE #{self.name}")
  end
  
  # Json values are stored in the database as a string
  def db_json
    JSON.parse(self[:db_json])
  end
  
  def db_json=(value)
    self[:db_json] = value
  end
  
end
