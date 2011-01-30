class Task < ActiveRecord::Base
  
  attr_accessor :project_name
  
  normalize_attributes :name
    
  belongs_to :project, :touch => true

  before_validation :create_or_associate_project_from_project_name, :on => :create
    
  validates_lengths_from_database
  validates_presence_of :project
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id 
  
  private
  
  def create_or_associate_project_from_project_name
    self.project = Project.find_or_create_by_name project_name if project_name.present? # can't use :if => :project_name in the before_validation call, as it is called even when project_name is ""
  end 
  
end
