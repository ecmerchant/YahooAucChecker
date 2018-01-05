Rails.application.routes.draw do

  root to: 'products#sort'

  get 'products/sort'
  post 'products/sort'

  post 'products/import'

  post 'products/export'
  get 'products/export'

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => {
   :registrations => 'users/registrations'
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
