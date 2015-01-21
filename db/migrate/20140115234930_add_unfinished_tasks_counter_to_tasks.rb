class AddUnfinishedTasksCounterToTasks < ActiveRecord::Migration
  def change
    add_column :task_lists, :todo_tasks_count, :integer, :default => 0

    TaskList.all.each do |t|
      t.update_attribute :todo_tasks_count, t.tasks.where(done: false).count
    end

    add_index :task_lists, :todo_tasks_count
  end
end
