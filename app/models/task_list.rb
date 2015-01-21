class TaskList < ActiveRecord::Base
  belongs_to :user
  has_many :tasks, dependent: :delete_all

  validates :name, :user, presence: true
end
