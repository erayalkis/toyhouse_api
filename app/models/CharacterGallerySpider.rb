class CharacterGallerySpider < Kimurai::Base
   
  @name = 'character_gallery_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    cookies: [{name: "laravel_session", value: Rails.application.credentials.account_cookie, domain: "toyhou.se"}]
  }

  def self.instance(url)
    @start_urls = [url]


    gallery = self.parse!(:parse, url: @start_urls[0])
    return gallery
  end

  def parse(response, url:, data: {})
    character = {}

   
    unless response.css('input.btn-success').empty?
      browser.click_button response.css('input.btn-success')[0]['value']
      response = browser.current_response
    end
    if response.css('ul.magnific-gallery').empty?
      return { msg: 'Character has no images or character profile is locked!', status: 422 }
    end
    character[:name] = response.css('li.character-name').text.strip
    character[:gallery] = []
    response.css('div.thumb-image > a').each { |a| character[:gallery] << a['href'] }
    return character
  end
end