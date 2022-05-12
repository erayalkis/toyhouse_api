class RequestsController < ApplicationController

  def cache_gallery
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end

    character = SpiderManager::Character.call(params[:id], get_request_type(params))
    photos = character[:gallery]
    file_name = "#{params[:id]}-gallery.zip"
    file_path = Rails.root.join('tmp', 'cache', file_name)

    File.delete(file_path) if File.exists?(file_path)

    threads = []
    Zip::File.open(file_path, create: true) do |zip|
      photos.each_with_index do |photo, idx|
        link = photo[:link]
        threads << Thread.new { threaded_download(link, zip, idx) }
      end

      threads.map(&:join)
    end

    
    if character
      # render json: { msg: 'Character fetching successful!', status: 200 }, status: 200
      redirect_to download_gallery_path(id: params[:id], name: character[:name])
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse character link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
        tip: 'Psst, if you\'re having trouble with parameters, check out the Toyhouse API helper!',  
        status: 422 }, status: 422
    end
  end

  def download_gallery
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end

    file_name = "#{params[:id]}-gallery.zip"
    file_path = Rails.root.join('tmp', 'cache', file_name)

    if File.exists?(file_path)
      send_data(File.open(file_path), type: 'application/zip', disposition: 'attachment', filename: file_name, stream: false)
    end
  end

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