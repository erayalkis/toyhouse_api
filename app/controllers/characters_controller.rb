class CharactersController < ApplicationController
  before_action :ensure_id_exists

  def profile
    fetch_and_send_response("default")
  end

  def details
    fetch_and_send_response("details_only")
  end

  def gallery
    fetch_and_send_response("gallery_only")
  end

  def favorites
    fetch_and_send_response("favorites")
  end

  private

  def ensure_id_exists
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end
  end
  
  def fetch_and_send_response(scraper_type)
    data = fetch_character_data(scraper_type)
    respond_with_data(data)
  end

  def fetch_character_data(scraper_type)
    character_data = SpiderManager::Character.call(params[:id], scraper_type)
    character_data
  end

  def respond_with_data(character_data)
    if character_data
      render json: character_data, status: 200
    else
      render json: { 
        msg: "Something went wrong while processing your character!", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 500
    end
  end

end