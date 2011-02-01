class AddEstimationToTasks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :estimation, :float
  end

  def self.down
    remove_column :tasks, :estimation
  end
end
