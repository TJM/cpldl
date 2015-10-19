Rails.application.routes.draw do

  root 'home#index'

  devise_for :users
  get 'user_accounts/new', as: :user_account

  resource :account, only: [:show, :update]
  resource :profile, only: [:show, :update]
  resources :courses, only: [:index, :show] do
    resources :lessons, only: [:index, :show]
  end

  mount Ckeditor::Engine => '/ckeditor'

  namespace :admin do
    resources :dashboard
    resources :courses
    # resources :attachments # TODO: do we need a global view of all attachments?
  end
end
