require 'spec_helper'

describe Api::TasksController, type: :controller do

  context "logged in user" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:list) { user.task_lists.first }
    let(:task1) { list.tasks[0] }
    let(:task2) { list.tasks[1] }

    before do
      create(:task_list, user: user)
      2.times { create(:task, task_list: list) }
      sign_in(user)
    end

    describe "#index" do
      it "Returns tasks from the list in JSON" do
        get :index, task_list_id: list.id

        response.body.should == [task1, task2].to_json
      end

      it "Raises RecordNotFound when getting tasks from non-existing list" do
        expect {
          get :index, task_list_id: 0
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "Returns 401 when getting other user task" do
        other_user_list = create(:task_list)
        get :index, task_list_id: other_user_list.id

        response.status.should == 401
        response.body.should == { 'error' => "You don't have permission to view this item." }.to_json
      end
    end

    describe "#create" do
      let(:new_task) do
        post :create, task_list_id: list.id, task: { description: 'do something' }
      end

      it "Adds a record to the database" do
        expect {
          new_task
        }.to change(Task, :count).by(1)
      end

      it "Returns 200 OK" do
        new_task
        response.should be_success
      end

      it "Returns created task as JSON" do
        new_task

        resp = JSON.parse(response.body)
        resp["id"].should == be_an(Integer)
        resp["done"].should == false
        resp["description"].should == 'do something'
      end

      it "Puts new task at the top of the list" do
        t1, t2 = task1, task2
        new_task

        resp = JSON.parse(response.body)
        resp["position"].should == 1
        t1.reload.position == 2
        t2.reload.position == 3
      end

      it "Raises an error when task description is missing" do
        expect {
          post :create, task_list_id: list.id, task: {}
        }.to raise_error(ActionController::ParameterMissing)
      end

      it "Raises an error when task description is too long > 250 chars" do
        expect {
          post :create, task_list_id: list.id, task: { description: "A"*251 }
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Returns 401 when creating task in other user task list" do
        other_user_list = create(:task_list)
        post :create, task_list_id: other_user_list.id, task: { description: "you should do this" }

        response.status.should == 401
        response.body.should == { 'error' => "You don't have permission to view this item." }.to_json
      end
    end

    describe "#update" do
      let(:update_task) do
        patch :update, task_list_id: list.id, id: task1.id,
          task: { description: 'new task description', done: true }
      end

      it "Updates given task" do
        update_task
        task1.reload.description.should == 'new task description'
        task1.done.should == true
      end

      it "Returns 200 OK" do
        update_task

        response.status.should == 200
      end

      it "Returns updated task as JSON" do
        update_task

        resp = JSON.parse(response.body)
        resp['description'].expect == 'new task description'
        resp['done'].should == true
      end

      it "Raises 401 error when updating task of another user." do
        other_user_list = create(:task_list, user: user2)
        patch :update, task_list_id: other_user_list.id, id: task1.id,
          task: { description: "you should do this", done: true }

        response.status.should == 401
        response.body.should == { 'error' => "You don't have permission to view this item." }.to_json
      end
    end

    describe "#destroy" do
      let(:delete_task) do
        delete :destroy, task_list_id: list, id: task1.id
      end

      it "Removes task from database" do
        delete_task
        expect { task1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "Returns 200 OK" do
        delete_task

        response.status.should == 200
      end

      it "Returns 401 if trying to remove other users task" do
        other_task = create(:task)
        delete :destroy, task_list_id: other_task.task_list.id, id: other_task.id

        response.status.should == 401
        response.body.should == { 'error' => "You don't have permission to view this item." }.to_json
      end
    end
  end
end
