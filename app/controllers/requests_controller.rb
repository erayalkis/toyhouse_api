class RequestsController < ApplicationController

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

  def scrape_user_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    user_data = SpiderManager::User.call(params[:id])

    if user_data
      render json: user_data, status: 200
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse user link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
      }, 
      status: 422
    end
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

  def threaded_download(link, zip, idx)
    puts "Downloading #{link}..."
    image = URI.open(link)
    return unless image

    data_type = link.split(".")[3];
    if (data_type.length > 4)
      data_type = data_type.split("?")[0];
    end

    zip.add("#{idx}.#{data_type}", image)
    puts "#{link} complete..."
  end

end