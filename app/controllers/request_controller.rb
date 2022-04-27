class RequestController < ApplicationController

  def scrape_character_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end

    results = ToyhouseScraper.call(params[:id], get_request_type(params))

    if results
      render json: results, status: 200
    else
      render json: { 
        msg: "Invalid Toyhouse character link or private profile.", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
      }, status: 422
    end
  end

  def scrape_user_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    response = UserSpider.instance("https://toyhou.se/#{params[:id]}")

    unless response
      render json: { 
        msg: 'Please pass in a valid Toyhouse user link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
      }, 
      status: 422
    end

    render json: response
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