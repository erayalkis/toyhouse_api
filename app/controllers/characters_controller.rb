class CharactersController < ApplicationController

  def scrape_character_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end

    character_data = SpiderManager::Character.call(params[:id], get_request_type(params))

    if character_data
      render json: character_data, status: 200
    else
      render json: { 
        msg: "Something went wrong while processing your character!", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 500
    end
  end

  def profile
  end

  def details 
  end

  def gallery
  end

  private

  def get_request_type(params)
    case
      when params[:gallery_only]
        return "gallery_only"
      when params[:details_only]
        return "details_only"
      else
        return nil
    end
  end

end