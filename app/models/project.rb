class Project < ActiveRecord::Base
  
  normalize_attributes :name
  
  has_many :tasks, :dependent => :destroy 

  validates_lengths_from_database  
  validates :name, :presence => true, :uniqueness => true
end
