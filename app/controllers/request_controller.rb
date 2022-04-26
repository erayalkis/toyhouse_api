class RequestController < ApplicationController
  before_action :get_authorizations

  def scrape_character_profile
    unless params[:id]
      return render json: { msg: 'Please pass in a Toyhouse profile ID!' }, status: 404
    end

    begin
      case
        when params[:gallery_only]
          response = CharacterGallerySpider.instance("https://toyhou.se/#{params[:id]}/gallery", @auths)
        when params[:details_only]
          response = CharacterDetailsSpider.instance("https://toyhou.se/#{params[:id]}", @auths)
        else
          response = CharacterSpider.instance("https://toyhou.se/#{params[:id]}")
      end
    rescue => err
      puts err
      render json: { 
        msg: "Invalid Toyhouse character link or private profile.", 
        msg_desc: "The profile you're trying to fetch has custom HTML or it is a locked profile.", 
        }, status: 422
      return
    end

    unless response
      render json: { 
        msg: 'Please pass in a valid Toyhouse character link!', 
        msg_desc: 'The profile you\'re trying to fetch has custom HTML or it is a locked profile.',
      }, 
      status: 422
    end

    render json: response
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