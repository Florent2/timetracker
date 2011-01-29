class Task < ActiveRecord::Base
  
  attr_accessor :project_name
  
  normalize_attributes :name
    
  belongs_to :project, :touch => true
  
  validates_lengths_from_database
  validates_length_of :project_name, :maximum => 0, :if => :project, :on => :create, :message => "You can't write a project name AND choose a project in the list"
  validate :create_or_associate_project_from_project_name, :on => :create
  validates_presence_of :project
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id 
  
  private
  
  def create_or_associate_project_from_project_name
    self.project = Project.find_or_create_by_name project_name if project_name.present? # can't use :if => :project_name in the validation call, as it is called even when project_name is ""
  end 
  
end
