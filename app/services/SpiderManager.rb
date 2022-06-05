module SpiderManager

  class Character < ApplicationService
    def initialize(id, req_type)
      @id = id
      @auths = SpiderManager::get_authorizations
      @req_type = req_type
    end

    def call
      begin
        case @req_type
          when "gallery_only"
            response = Spiders::CharacterGallerySpider.instance("https://toyhou.se/#{@id}/gallery", @auths)
          when "details_only"
            response = Spiders::CharacterDetailsSpider.instance("https://toyhou.se/#{@id}", @auths)
          when "favorites"
            response = Spiders::CharacterFavoritesSpider.instance("https://toyhou.se/#{@id}/favorites", @auths)
          else
            response = Spiders::CharacterSpider.instance("https://toyhou.se/#{@id}", @auths)
        end
      rescue => err
        puts err
        return nil
      end

      return response
    end

  end

  class User < ApplicationService
    def initialize(id, req_type)
      @id = id
      @req_type = req_type
    end

    def call
      begin
        response = Spiders::UserSpider.instance("https://toyhou.se/#{@id}")
      rescue => err
        puts err
        return nil
      end

      return response
    end
  end

  def self.get_authorizations
    # Use a set for holding auths so that lookup time is O(1) !!!!!!!!!!!!!!!!!!!!!!!
    # Pass the auths to the instance method of CharacterGallerySpider (and maybe others) and check if the profile name on the 
      # page matches any in the auths set to authorize users
    @auths = Spiders::AuthorizationsSpider.instance("https://toyhou.se/~account/authorizers", @auths)
  end
end