class RafflesController < ApplicationController

  def calculate_tickets
    tickets = {}
    fav_ticket_count = set_ticket_count_if_exists("fav")
    comment_ticket_count = set_ticket_count_if_exists("comment")
    sub_ticket_count = set_ticket_count_if_exists("subscriber")

    favorites = SpiderManager::Character.call(params[:id], "favorites")
    favorites[:favorites].each do |favorite| 
      username = favorite[:username]
      tickets[username] = {}
      tickets[username][:ticket_count] = fav_ticket_count
      tickets[username][:image] = favorite[:image]
    end

    seen = Set.new
    if params[:must_comment]
      comments = SpiderManager::Character.call(params[:id], "comments")
      comments[:comments].each do |comment|
        username = comment[:user][:username]
        if tickets.has_key?(username) && !seen.include?(username)
          tickets[username][:ticket_count] += comment_ticket_count 
        end
        seen.add(username)
      end
    end
    
    owner_id = favorites[:owner][:name]
    if params[:must_subscribe]
      subscribers = SpiderManager::User.call(owner_id, "subscribers")
      subscribers[:subscribers].each do |subscriber|
        username = subscriber[:username]
        tickets[username][:ticket_count] += sub_ticket_count if tickets.has_key?(username) 
      end
    end

    render json: tickets
  end


  private

  def set_ticket_count_if_exists(option_type)
    ticket_count_param = "#{option_type}_ticket_count"
    return 1 if params[ticket_count_param].nil?
    params[ticket_count_param].to_i
  end

end