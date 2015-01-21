Todo::Application.routes.draw do
  devise_for :users

  namespace :api, defaults: {format: :json} do
    devise_scope :user do
      resource :session, only: [:create, :destroy]
    end

    resources :l, :as => :task_lists, :controller => :task_lists, only: [:index, :create, :update, :destroy, :show] do
      resources :tasks, only: [:index, :create, :update, :destroy]
    end
  end

  root 'main#index'

  get '/dashboard' => 'templates#index'
  get '/l/:id' => 'templates#index'
  get '/templates/:template.html' => 'templates#template', :contains => { :template => /.+/ }
end
