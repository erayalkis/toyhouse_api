Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope :character, constraints: { id: /[^\/]+/ } do
    get '/:id', to: 'characters#profile'
    get '/:id/gallery', to: 'characters#gallery'
    get '/:id/details', to: 'characters#details'
    get '/:id/favorites', to: 'characters#favorites'
  end

  scope :user do
    get '/:id', to: 'users#profile'
  end

  get '/app_status', to: 'application#app_status'
end
