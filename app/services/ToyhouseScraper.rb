class ToyhouseScraper

  def initialize(id, req_type)
    @id = id
    @auths = get_authorizations
    @req_type = req_type
  end

  def scrape
    begin
      case @req_type
        when "gallery_only"
          response = CharacterGallerySpider.instance("https://toyhou.se/#{@id}/gallery", @auths)
        when "details_only"
          response = CharacterDetailsSpider.instance("https://toyhou.se/#{@id}", @auths)
        else
          response = CharacterSpider.instance("https://toyhou.se/#{@id}")
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
    @auths = AuthorizationsSpider.instance("https://toyhou.se/~account/authorizers")
  end

end