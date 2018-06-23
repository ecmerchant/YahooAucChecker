require 'resque/server'

Rails.application.routes.draw do

  root to: 'products#sort'

  get 'products/sort'
  post 'products/sort'

  get 'products/setup'
  post 'products/setup'

  post 'products/converse'

  post 'products/import'

  post 'products/export'
  get 'products/export'

  mount Resque::Server.new, at: "/resque"

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => {
   :registrations => 'users/registrations'
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
