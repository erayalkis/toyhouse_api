Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/character', to: 'requests#scrape_character_profile'
  get '/user', to: 'requests#scrape_user_profile'
  get '/app_status', to: 'application#app_status'
  get '/cache_gallery', to: 'requests#cache_gallery'
  get '/download_gallery', to: 'requests#download_gallery'
end
