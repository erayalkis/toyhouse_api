class CharactersController < ApplicationController
  before_action :ensure_id_exists

  def profile
    character_data = SpiderManager::Character.call(params[:id], "default")

    if character_data
      render json: character_data, status: 200
    else
      render json: { 
        msg: "Something went wrong while processing your character!", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 500
    end
  end

  def details
    character_data = SpiderManager::Character.call(params[:id], "details_only")

    if character_data
      render json: character_data, status: 200
    else
      render json: { 
        msg: "Something went wrong while processing your character!", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 500
    end
  end

  def gallery
    character_data = SpiderManager::Character.call(params[:id], "gallery_only")

    if character_data
      render json: character_data, status: 200
    else
      render json: { 
        msg: "Something went wrong while processing your character!", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 500
    end
  end

  private

  def ensure_id_exists
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end
  end
end