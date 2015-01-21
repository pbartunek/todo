class TemplatesController < ApplicationController

  before_filter :authenticate_user!

  def template
    render :template => 'templates/' + params[:template], :layout => nil
  end
end
