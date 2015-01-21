class Api::TaskListsController < ApplicationController

  before_filter :check_ownership, only: [:show, :update, :destroy]

  def index
    render json: current_user.task_lists.order('created_at desc')
  end

  def show
    render json: list.as_json(include: :tasks)
   end

  def create
    new_list = current_user.task_lists.create!(list_params)
    Task.new(description: 'later', task_list: new_list).save!(validate: false)

    render json: new_list
  end

  def update
    list.update_attributes(list_params)

    render json: list
  end

  def destroy
    list.destroy

    render nothing: true
  end

  private

  def check_ownership
    access_deny if current_user.id != list.user_id
  end

  def access_deny
    render json: {error: "You don't have permission to view this item."}, status: :unauthorized
  end

  def list_params
    params.require(:list).permit(:name)
  end

  def list
    @task_list ||= TaskList.includes(:tasks).find(params[:id])
  end
end
