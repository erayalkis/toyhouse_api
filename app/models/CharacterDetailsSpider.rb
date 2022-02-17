class CharacterDetailsSpider < Kimurai::Base
   
  @name = 'character_details_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url)
    @start_urls = [url]


    details = self.parse!(:parse, url: @start_urls[0])
    return details
  end

  def parse(response, url:, data: {})
    character = {}

    unless response.css('input.btn-success').empty?
      browser.click_button response.css('input.btn-success')[0]['value']
      response = browser.current_response
    end

    if response.css('div.col-sm-12.content-main > div.character-profile').empty?
      return nil
    end

    character[:name] = response.css('h1.display-4').text.strip
    character[:profile_img] = response.css('img.profile-name-icon')[0]["src"]
    return character
  end
end