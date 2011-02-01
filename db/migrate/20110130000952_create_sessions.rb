class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.integer :task_id
      t.datetime :start
      t.datetime :finish

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
