class RequestController < ApplicationController

  def download_gallery
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    character = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery")
    links = character[:gallery]

    zip = Zip::File.new("#{character[:name]}-gallery")

    links.each_with_index do |link, idx|
      image = open(link).read

      zip.add(i, image)
    end

    send_file zip
  end

  def scrape_character_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    if params[:id] && params[:gallery_only] == "true"
      response = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery")
    else
      response = CharacterSpider.instance("https://toyhou.se/#{params[:id]}")
    end

    if response
      render json: response
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse character link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
        tip: 'Psst, if you\'re having trouble with parameters, check out the Toyhouse API helper!',  
        status: 422 }, status: 422
    end
  end

  def scrape_user_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    response = UserSpider.instance("https://toyhou.se/#{params[:id]}")

    if response
      render json: response
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse user link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
        tip: 'Psst, if you\'re having trouble with parameters, check out the Toyhouse API helper!',  
        status: 422 }, status: 422
    end

  end

end