class RequestController < ApplicationController

  def scrape
    response = CharacterSpider.instance("https://toyhou.se/#{params[:id]}")

    render json: response
  end

end