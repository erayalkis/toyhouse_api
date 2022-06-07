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
          when "comments"
            response = Spiders::CharacterCommentsSpider.instance("https://toyhou.se/#{@id}/comments", @auths)
          else
            response = Spiders::CharacterSpider.instance("https://toyhou.se/#{@id}", @auths)
        end
      rescue => err
        code = SpiderManager::parse_scraper_error(err)

        case code
          when 404
            return { msg: 'The character you\'re requesting doesn\'t exist!', status: 404 }
          when 403
            return { msg: 'Toyhouse has denied access to the character you\'re requesting!', status: 403 }
        end

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
        case @req_type
          when "subscribers"
            response = Spiders::UserSubscribersSpider.instance("https://toyhou.se/#{@id}/stats/subscribers")
          when "subscriptions"
            response = Spiders::UserSubscriptionsSpider.instance("https://toyhou.se/#{@id}/stats/subscriptions")
          else
            response = Spiders::UserSpider.instance("https://toyhou.se/#{@id}")
        end
      rescue => err
        code = SpiderManager::parse_scraper_error(err)

        case code
          when 404
            return { msg: 'The user you\'re trying to fetch doesn\'t exist!', status: 404 }
          when 403
            return { msg: 'The user you requested has their details hidden!', status: 403 }
        end

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

  def self.parse_scraper_error(err)
    # Evil string parsing code
    # Replace this with Regex soon!!!
    err.message.split(":")[2].split("=")[0].split('\'')[1].strip.to_i
  end
end