class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :description, null: false
      t.boolean :done, default: false, null: false
      t.belongs_to :task_list, null: false

      t.timestamps
    end
  end
end
