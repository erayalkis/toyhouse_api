class RafflesController < ApplicationController

  def calculate_tickets
    comments = SpiderManager::Character.call(params[:id], "comments")
    favorites = SpiderManager::Character.call(params[:id], "favorites")
    owner_id = comments[:owner][:name]
    subscribers = SpiderManager::User.call(owner_id, "subscribers")

    tickets = {}
    favorites[:favorites].each do |favorite| 
      username = favorite[:username]
      tickets[username] = 1
    end

    comments[:comments].each do |comment|
      username = comment[:user][:username]
      tickets[username] += 1 if tickets.has_key?(username)
    end
    
    subscribers[:subscribers].each do |subscriber|
      username = subscriber[:username]
      tickets[username] += 1 if tickets.has_key?(username) 
    end

    render json: tickets
  end

end