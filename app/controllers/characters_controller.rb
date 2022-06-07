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

  def comments
    fetch_and_send_response("comments")
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
    render json: character_data, status: character_data[:status] || 200
  end
end