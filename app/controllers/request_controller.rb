class RequestController < ApplicationController
  def cache_gallery
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end

    character = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery")
    links = character[:gallery]
    file_name = "#{character[:name]}-gallery"
    file_path = "/public/content/#{file_name}.zip"
    
    File.delete(file_path) if File.exists?(file_path)

    puts "---- Creating file #{file_name} on #{file_path} ----"
    Zip::File.open(file_path, create: true) do |zip|
      links.each_with_index do |link, idx|
        puts link
        image = URI.open(link)
        
        data_type = link.split(".")[3];
        if (data_type.length > 4)
          data_type = data_type.split("?")[0];
        end

        puts "Adding image to #{file_path}"
        zip.add("#{idx}.#{data_type}", image)
      end
    end

    puts "---- Sending response... ----"
    if character
      render json: { msg: 'Character fetching successful!', status: 200 }, status: 200
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
      return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
    end
    character = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery")
    file_name = "#{character[:name]}-gallery"
    file_path = "/public/content/#{file_name}.zip"
    
    if File.exists?(file_path)
      send_data(File.open(file_path), type: 'application/zip', disposition: 'attachment', filename: file_name, stream: false)
    end

    # clear_cache(file_path) # Heroku already gets rid of files automatically
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

  private 

  # def clear_cache(path)
  #   puts "Clearing zip on path: #{path}"
  #   FileUtils.rm_rf(Dir[path]) 
  # end
end