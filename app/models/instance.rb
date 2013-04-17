class Instance < ActiveRecord::Base
  attr_accessible :name, :server_id
  belongs_to :server
  
  before_create do
    logger.debug("creating new database at #{Time.now}")
    self.server.make_connection
    self.server.sql.query("CREATE DATABASE #{self.name}")
  end
  before_save do
    self.db_json ||= {:tables=>[], :relations => []}.to_json
  end

  
  
  after_destroy do
    self.server.make_connection
    self.server.sql.query("DROP DATABASE #{self.name}")
  end
  
  # Json values are stored in the database as a string
  def db_json
    self[:db_json]
  end
  
  def db_json=(value)
    self[:db_json] = value
  end
  
end
