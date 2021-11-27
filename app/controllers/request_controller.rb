class RequestController < ApplicationController

  def scrape_character_profile

    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse link!', status: 404 }, status: 404
    end

    response = CharacterSpider.instance("https://toyhou.se/#{params[:id]}")

    if response
      render json: response
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse link!', 
        tip: 'Psst, if you\'re having trouble with parameters, check out the Toyhouse API helper!',  
        status: 422 }, status: 422
    end
  end

  def scrape_user_profile
    
  end

end