Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :v1, default: {format: :json} do

    resources :users, only: [:index, :create, :show] do
      member do # Tienen una instancia de usuario
        post :name
      end
      collection do #Sin instancias de usuario
        delete :destroy
        post :image
        put :password
        post :register
        post :login
        get :logout
      end
    end

    resources :games, only: [:index, :create, :show] do
      member do # Tienen una instancia de usuario
        put '', action: :update
        post :teams, to: 'games#create_teams'
        get :teams, to: 'games#get_teams'
        put 'teams/:team_id', action: :join_teams
        post 'users', to: 'games#add_users'
        get 'users', to: 'games#get_users'
        get 'scores', to: 'games#get_scores'
        put 'scores/:entity_id', to: 'games#increase_score'
        get 'cards/:user_id', action: :get_user_cards
        post 'cards', to: 'games#take_card'
        put 'cards', to: 'games#reset_game'
        put 'cards/:card_id', to: 'games#throw_card'
        get :card
      end
    end

  end

end
