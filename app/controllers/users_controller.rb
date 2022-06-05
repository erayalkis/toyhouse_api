class UsersController < ApplicationController
  before_action :ensure_id_exists

  def profile
    fetch_and_send_response("profile")
  end

  def subscribers
    fetch_and_send_response("subscribers")
  end

  private

  def ensure_id_exists
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end
  end

  def fetch_and_send_response(scraper_type)
    data = fetch_user_data(scraper_type)
    respond_with_data(data)
  end

  def fetch_user_data(scraper_type)
    user_data = SpiderManager::User.call(params[:id], scraper_type)
    user_data
  end

  def respond_with_data(user_data)
    if user_data
      render json: user_data, status: 200
    else
      render json: { 
        msg: "Something went wrong while processing the requested user!", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 500
    end
  end
end