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
  
  after_create :interrupt_previous_running_task_if_the_new_one_is_running
  
  scope :actives, where(:archived => false)
  
  def archive!
    return false if archived?
    interrupt!
    update_attributes :archived => true
  end
  
  def self.by_dates_from(tasks, date)
    result = {}
    (date..Date.today).each { |date| result[date] = tasks.on_date(date) }
    result.reject! { |date, tasks| tasks.empty? }
    Hash[result.sort { |a, b| b <=> a }] # this revert the dates order: now from the most recent to the oldest (from http://stackoverflow.com/questions/4339553/sort-hash-by-key-return-hash-in-ruby)
  end
  
  def duration_current
    return 0.0 if !running?
    sessions.running.first.duration
  end
  
  def duration_on_date(date)
    sessions.on_date(date).inject(0.0) { |sum, session| sum + session.duration }.round 2
  end
  
  def duration_total
    reload.sessions.inject(0.0) { |sum, session| sum + session.duration }.round 2
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
    update_attributes! :archived => false
    sessions.create :start => DateTime.now
  end
  
  def running?
    sessions.exists?(:finish => nil)
  end
  
  def self.running_task
    Task.running_tasks.first
  end
  
  def status
    return "archived" if archived?
    return "running" if running?
    "interrupted"
  end
  
  private
  
  def create_or_associate_project_from_project_name
    self.project = Project.find_or_create_by_name project_name if project_name.present? # can't use :if => :project_name in the before_validation call, as it is called even when project_name is ""
  end 

  def interrupt_previous_running_task_if_the_new_one_is_running
    Task.running_tasks.where("tasks.id <> ?", id).first.try :interrupt!
  end

  def self.on_date(date)
    where("sessions.start" => date.beginning_of_day..date.end_of_day).includes(:sessions)
  end
    
  def self.running_tasks
    where("sessions.finish" => nil).includes(:sessions)
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
#  estimation :float
#  archived   :boolean         default(FALSE)
#

