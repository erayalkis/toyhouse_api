class RafflesController < ApplicationController

  def calculate_tickets
    comments = SpiderManager::Character.call(params[:id], "comments")
    favorites = SpiderManager::Character.call(params[:id], "favorites")
    owner_id = comments[:owner][:name]
    subscribers = SpiderManager::User.call(owner_id, "subscribers")

    tickets = {}
    favorites[:favorites].each do |favorite| 
      username = favorite[:username]
      tickets[username] = {}
      tickets[username][:ticket_count] = 1
      tickets[username][:image] = favorite[:image]
    end

    comments[:comments].each do |comment|
      username = comment[:user][:username]
      tickets[username][:ticket_count] += 1 if tickets.has_key?(username)
    end
    
    subscribers[:subscribers].each do |subscriber|
      username = subscriber[:username]
      tickets[username][:ticket_count] += 1 if tickets.has_key?(username) 
    end

    render json: tickets
  end

end