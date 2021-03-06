Rails.application.routes.draw do
  blacklight_for :catalog

  # Devise settings
  devise_for :users, skip: [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    patch 'users/:id' => 'devise/registrations#update', :as => 'user_registration'
  end

  Hydra::BatchEdit.add_routes(self)

  root to: 'homepage#index'

  # Administrative URLs
  mount Hydra::RoleManagement::Engine => '/admin'
  namespace :admin do
    # Job monitoring
    constraints ResqueAdmin do
      mount Resque::Server, at: 'queues'
    end
  end

  resources :comments
  resources :tags
  resources :tag_cats
  resources :works, except: [:new, :create, :destroy]
  resources :actors, except: [:new, :create, :destroy]
  resources :exhibitions, except: [:new, :create, :destroy]
  resources :transactions, except: [:new, :create, :destroy]
  resources :shipments, except: [:new, :create, :destroy]
  resources :lists, only: [:index, :show] do
    resources :list_items, except: [:index, :show]
  end

  resources :generic_files, only: [:index]
  resources :representations, only: [:index]

  # Lakeshore API
  scope "api" do
    post "reindex", to: "reindex#update"
  end

  # Sufia should come last because in production it will 404 any unknown routes
  mount Sufia::Engine => '/'
end
