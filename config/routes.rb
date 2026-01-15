Rails.application.routes.draw do

  # Health check endpoint pour Docker et monitoring
  get 'up', to: 'health#show'
  

  resources :product_categories
  resources :products
  get "boutique", to: "boutique#index", as: :boutique
  get 'maintenance', to: 'maintenance#index', as: :maintenance
  get 'contact', to: 'contact#index', as: :contact
  
  namespace :admin do
    resources :comments, only: %i[index update destroy]
  end
  
 # config/routes.rb
get "emplois", to: "job_offers#emplois", as: :emplois
resources :job_offers
get "mes_encheres", to: "auctions#mes_encheres", as: :mes_encheres
get "offre_de_service", to: "services#offre_de_service", as: :offre_de_service
resources :services
resources :auctions do
  member do
    patch :publish
    patch :start
    patch :close
  end
  resources :bids, only: %i[create]
end

# Page d'accueil des enchères
get "encheres", to: "encheres#index", as: :encheres

  root 'home#accueil'

  resources :posts, param: :slug do
    resources :comments, only: [:create], shallow: true do
      collection do
        get :success
      end
      member do
        post :flag
      end
    end
  end
  resources :tags
  resources :categories


  # config/routes.rb
get 'magazine', to: 'magazine#index', as: :magazine

  get 'dashboard/index'
    devise_for :users, 
      skip: [:sessions, :registrations], # Important : skip les routes qu'on va redéfinir
      controllers: {
        sessions: 'users/sessions',
        registrations: 'users/registrations',
        passwords: 'users/passwords',
        unlocks: 'users/unlocks'
      }

    # Redéfinition personnalisée des routes principales
  devise_scope :user do
    # sessions
    get    'connexion'   => 'users/sessions#new',     as: :login
    post   'connexion'   => 'users/sessions#create',  as: :user_session
    delete 'deconnexion' => 'users/sessions#destroy', as: :logout

    # registrations (inscription + edition)
    get   'inscription' => 'users/registrations#new',    as: :signup
    post  'inscription' => 'users/registrations#create', as: :user_registration

    get   'profil/edit' => 'users/registrations#edit',   as: :edit_user_registration
    put   'profil'      => 'users/registrations#update'
    patch 'profil'      => 'users/registrations#update'
  end
  
 get 'mon_profil', to: 'users#show', as: :user_profile
  namespace :admin do
    resources :users do
      member do
        patch :block
        patch :unblock
      end
    end
    resource :site_setting, only: %i[edit update], path: "parametres"
  end

  # config/routes.rb
  resource :profile, only: %i[show update] do
    member do
      get :completion_enchere_profile # ← page de formulaire
      patch :save_enchere_profile     # ← soumission
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
