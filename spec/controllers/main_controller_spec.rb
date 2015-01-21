require 'spec_helper'

describe MainController do
  let(:user) { create(:user) }

  describe "#index" do
    it "Redirects to login page if user is not signed in " do
      get :index

      response.should redirect_to(new_user_session_path)
    end

    it "Redirects to dashboard path if user is signed in" do
      sign_in(user)
      get :index

      response.should redirect_to(dashboard_path)
    end
  end
end
