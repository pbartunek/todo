class Task < ActiveRecord::Base
  belongs_to :task_list, counter_cache: true

  validates_presence_of :description, message: 'Sorry, task name can\'t be empty.'
  validates_length_of   :description, maximum: 250, message: 'Sorry, task can\'t be longer than 250 characters.'
  validates_presence_of     :task_list_id, message: 'Sorry, no task list specified.'
  validates_numericality_of :task_list_id, message: 'Sorry, invalid task list ID.'

  after_save    :update_todo_tasks_count
  after_destroy :update_todo_tasks_count

  acts_as_list scope: :task_list, add_new_at: :top

  default_scope { where('done = false').order('position asc') }

  private

  def update_todo_tasks_count
    self.task_list.todo_tasks_count = (self.task_list.tasks.where(done: false).count - 1)
    self.task_list.save
  end
end
