class Api::TasksController < ApplicationController

  before_filter :check_ownership

  def index
    render json: list.tasks
  end

  def create
    new_task = list.tasks.create!(task_params)

    render json: new_task, status: 201
  end

  def update
    task.update_attributes(task_params)
    render json: task
  end

  def destroy
    task.destroy
    render nothing: true
  end

  private

  def task_params
    params.require(:task).permit(:description, :done, :position)
  end

  def list
    @task_list ||= TaskList.find(params[:task_list_id])
  end

  def task
    @task ||= list.tasks.find(params[:id])
  end

  def check_ownership
    access_deny if current_user.id != list.user_id
  end

  def access_deny
    render json: { error: "You don't have permission to view this item." }, status: :unauthorized
  end
end
