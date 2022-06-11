class RafflesController < ApplicationController

  def calculate_tickets
    tickets = {}

    favorites = SpiderManager::Character.call(params[:id], "favorites")
    favorites[:favorites].each do |favorite| 
      username = favorite[:username]
      tickets[username] = {}
      tickets[username][:ticket_count] = set_ticket_count_if_exists("fav")
      tickets[username][:image] = favorite[:image]
    end

    owner_id = comments[:owner][:name]

    if params[:must_comment]
      comments = SpiderManager::Character.call(params[:id], "comments")
      comments[:comments].each do |comment|
        username = comment[:user][:username]
        tickets[username][:ticket_count] += set_ticket_count_if_exists("comment") if tickets.has_key?(username)
      end
    end
    
    if params[:must_subscribe]
      subscribers = SpiderManager::User.call(owner_id, "subscribers")
      subscribers[:subscribers].each do |subscriber|
        username = subscriber[:username]
        tickets[username][:ticket_count] += set_ticket_count_if_exists("subscribe") if tickets.has_key?(username) 
      end
    end

    render json: tickets
  end


  private

  def set_ticket_count_if_exists(option_type)
    ticket_count_param = "#{option_type}_ticket_count"
    return 1 if params[ticket_count_param].nil?
    params[ticket_count_param]
  end

end