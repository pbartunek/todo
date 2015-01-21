require 'spec_helper'

describe Api::TaskListsController do

  context "User with two task lists" do
    let(:user) { create(:user) }
    let(:first_list) { user.task_lists.first }
    let(:second_list) { user.task_lists.last }
    let(:other_list) { create(:task_list) }

    before do
      2.times { create(:task_list, user: user) }
    end

    describe "#index" do
      context "Authenticated as user" do
        before { sign_in(user) }

        it "Returns task list as JSON" do
          get :index

          response.body.should == [second_list, first_list].to_json
        end
      end

      context "Not authenticated" do
        it "Returns 401 HTTP status" do
          get :index, format: :json
          response.status.should == 401
          response.body.should   == {
            'error' => 'You need to sign in or sign up before continuing.'
          }.to_json
        end
      end
    end

    describe "#show" do
      context "Authenticated" do
        before { sign_in(user) }

        it "Returns specified task list as JSON" do
          get :show, id: first_list.id

          response.body.should == first_list.to_json(include: :tasks)
        end

        it "Returns 401 when user is trying to view other user task list" do
          get :show, id: other_list.id

          response.status.should == 401
        end

        it "Returns 404 not found when trying to view non-existing tasks list" do
          expect {
            get :show, id: 0
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "Not authenticated" do
        it "Returns 401 HTTP status" do
          get :show, id: first_list.id, format: :json
          response.status.should == 401
          response.body.should   == {
            'error' => 'You need to sign in or sign up before continuing.'
          }.to_json
        end
      end
    end

    describe "#create" do
      let(:new_list) do
        post :create, list: {name: 'new task list'}, format: :json
      end

      context "Authenticated" do
        before { sign_in(user) }

        it "Creates new list" do
          expect {
            new_list
          }.to change(TaskList, :count).by(1)
        end

        it "Returns 200 OK HTTP code" do
          new_list

          response.should be_success
        end

        it "Returns created task list as JSON" do
          new_list

          resp = JSON.parse(response.body)
          resp['id'].should == be_an(Integer)
          resp['name'].should == 'new task list'
          resp['user_id'].should == user.id
        end
      end

      context "Not authenticated" do
        it "Returns 401 HTTP status" do
          new_list

          response.status.should == 401
          response.body.should   == {
            'error' => 'You need to sign in or sign up before continuing.'
          }.to_json
        end
      end
    end

    describe "#update" do
      let(:update_list) do
        post :update, id: first_list.id, list: {name: 'new task list name'}, format: :json
      end

      context "Authenticated" do
        before { sign_in(user) }

        it "Updates task list in db" do
          update_list

          first_list.reload.name.should == 'new task list name'
        end

        it "Returns updated list as JSON" do
          post :update, id: first_list.id,
            list: { name: 'another task list name change'}, format: :json

          resp = JSON.parse(response.body)
          resp['id'].should == first_list.id
          resp['name'].should == 'another task list name change'
        end

        it "Returns 200 OK HTTP code" do
          update_list

          response.should be_success
        end

        it "Returns 404 HTTP code when updating non-existing record" do
          expect {
            patch :update, id: 0, taskList: { name: "new task list name" }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "Returns 401 when user is trying to update other user task list" do
          post :update, id: other_list.id, list: {name: 'new task list name'}, format: :json

          response.status.should == 401
        end
      end

      context "Not authenticated" do
        it "Returns 401 HTTP status" do
          update_list

          response.status.should == 401
          response.body.should   == {
            'error' => 'You need to sign in or sign up before continuing.'
          }.to_json
        end
      end
    end

    describe "#destroy" do
      let(:destroy_list) do
        delete :destroy, id: second_list.id, format: :json
      end

      context "Authenticated user" do
        before { sign_in(user) }

        it "Removes list" do
          destroy_list
          expect {
            second_list.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "Removes list" do
          expect {
            destroy_list
          }.to change(TaskList, :count).by(-1)
        end

        it "Returns 200 OK" do
          destroy_list

          response.should be_success
        end

        it "Raises 404 when trying to destroy non-existing list" do
          expect {
            delete :destroy, id: 0
          }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "Returns 401 when user is trying to remove other user task" do
          delete :destroy, id: other_list.id
          response.status.should == 401
        end
      end

      context "Not authenticated" do
        it "Returns 401 HTTP status" do
          destroy_list

          response.status.should == 401
          response.body.should   == {
            'error' => 'You need to sign in or sign up before continuing.'
          }.to_json
        end
      end
    end
  end
end
