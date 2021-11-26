class RequestController < ApplicationController

  def scrape
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse link!', status: 404 }, status: 404
    end

    response = CharacterSpider.instance("https://toyhou.se/#{params[:id]}")

    render json: response
  end

end