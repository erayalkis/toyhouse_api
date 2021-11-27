Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/character', to: 'request#scrape_character_profile'
  get '/user', to: 'request#scrape_user_profile'
end
