class Task < ActiveRecord::Base
  
  attr_accessor :project_name
  
  normalize_attributes :name
    
  belongs_to :project, :touch => true
  has_many :sessions, :dependent => :destroy
  accepts_nested_attributes_for :sessions, :reject_if => :all_blank 
     
  before_validation :create_or_associate_project_from_project_name, :on => :create
    
  validates_lengths_from_database
  validates_presence_of :project
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id 
  
  def current_duration
    return 0.0 if !running?
    sessions.running.first.duration
  end
  
  def duration
    sessions.inject(0.0) { |sum, session| sum + session.duration }.round 2
  end

  def interrupt!
    result = false
    if running?
      result = !!sessions.running.first.finish!
    end
    result
  end

  def resume!
    return false if running?
    Task.running_task.try :interrupt!
    self.sessions.create :start => DateTime.now
  end
  
  def running?
    sessions.exists?(:finish => nil)
  end
  
  def self.running_task
    Task.all.select { |task| task.running? }.first
  end
  
  def status
    if running? then "running" else "interrupted" end
  end
  
  private
  
  def create_or_associate_project_from_project_name
    self.project = Project.find_or_create_by_name project_name if project_name.present? # can't use :if => :project_name in the before_validation call, as it is called even when project_name is ""
  end 
  
end

# == Schema Information
#
# Table name: tasks
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  project_id :integer
#  created_at :datetime
#  updated_at :datetime
#

