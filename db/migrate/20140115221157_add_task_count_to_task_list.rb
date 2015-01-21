class AddTaskCountToTaskList < ActiveRecord::Migration
  def change
    add_column :task_lists, :tasks_count, :integer, :default => 0

    TaskList.all.each do |t|
      t.update_attribute :tasks_count, t.tasks.length
    end

    add_index :task_lists, :tasks_count
  end
end
