module SpiderManager

  class Character < ApplicationService
    def initialize(id, req_type)
      @id = id
      @auths = get_authorizations
      @req_type = req_type
    end

    def call
      begin
        case @req_type
          when "gallery_only"
            response = Spiders::CharacterGallerySpider.instance("https://toyhou.se/#{@id}/gallery", @auths)
          when "details_only"
            response = Spiders::CharacterDetailsSpider.instance("https://toyhou.se/#{@id}", @auths)
          else
            response = Spiders::CharacterSpider.instance("https://toyhou.se/#{@id}")
        end
      rescue => err
        puts err
        return nil
      end

      return response
    end

    private

    def get_authorizations
      # Use a set for holding auths so that lookup time is O(1) !!!!!!!!!!!!!!!!!!!!!!!
      # Pass the auths to the instance method of CharacterGallerySpider (and maybe others) and check if the profile name on the 
        # page matches any in the auths set to authorize users
      @auths = Spiders::AuthorizationsSpider.instance("https://toyhou.se/~account/authorizers")
    end
  end

  class User < ApplicationService

    def initialize(id)
      @id = id
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

end