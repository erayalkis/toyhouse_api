class RequestController < ApplicationController
  before_action :get_authorizations
  # def cache_gallery
  #   unless params[:id]
  #     return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
  #   end

  #   character = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery")
  #   links = character[:gallery]
  #   file_name = "#{character[:name]}-gallery.zip"
  #   file_path = Rails.root.join('public', 'content', file_name)
    
  #   File.delete(file_path) if File.exists?(file_path)

  #   Zip::File.open(file_path, create: true) do |zip|
  #     links.each_with_index do |link, idx|
  #       puts link
  #       image = URI.open(link)
        
  #       data_type = link.split(".")[3];
  #       if (data_type.length > 4)
  #         data_type = data_type.split("?")[0];
  #       end

  #       zip.add("#{idx}.#{data_type}", image)
  #     end
  #   end

  #   if character
  #     render json: { msg: 'Character fetching successful!', status: 200 }, status: 200
  #   else
  #     render json: { 
  #       msg: 'Please pass in a valid Toyhouse character link!', 
  #       msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
  #       tip: 'Psst, if you\'re having trouble with parameters, check out the Toyhouse API helper!',  
  #       status: 422 }, status: 422
  #   end
  # end

  # def download_gallery
  #   unless params[:id]
  #     return render json: { msg: 'Please pass in a Toyhouse profile ID!', status: 404 }, status: 404
  #   end
  #   character = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery")
  #   file_name = "#{character[:name]}-gallery.zip"
  #   file_path = Rails.root.join('public', 'content', file_name)
    
  #   if File.exists?(file_path)
  #     send_data(File.open(file_path), type: 'application/zip', disposition: 'attachment', filename: file_name, stream: false)
  #   end
  # end

  def scrape_character_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end

    begin
      if params[:id] && params[:gallery_only] == "true"
        response = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery", @auths)
      elsif params[:id] && params[:details_only] == "true"
        response = CharacterDetailsSpider.instance("https://toyhou.se/#{params[:id]}", @auths)
      else
        response = CharacterSpider.instance("https://toyhou.se/#{params[:id]}")
      end
    rescue => err
      puts err
      render json: { 
        msg: "Invalid Toyhouse link or private profile.", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
        }, status: 422
      return
    end

    if response
      render json: response
    else
      render json: { 
        msg: 'Please pass in a valid Toyhouse character link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
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
        status: 422 }, status: 422
    end

  end

  private

  def get_authorizations
    # Use a set for holding auths so that lookup time is O(1) !!!!!!!!!!!!!!!!!!!!!!!
    # Pass the auths to the instance method of CharacterGallerySpider (and maybe others) and check if the profile name on the 
      # page matches any in the auths set to authorize users
    @auths = AuthorizationsSpider.instance("https://toyhou.se/~account/authorizers")
  end

  def clear_cache(path)
    FileUtils.rm_rf(Dir[]) 
  end
end