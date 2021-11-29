class UserSpider < Kimurai::Base
  @name = 'user_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url)
    @start_urls = [url]


    user = self.parse!(:parse, url: @start_urls[0])
    return user
  end

  def parse(response, url:, data: {})
    user = {}

    unless response.css('input.btn-success').empty?
      browser.click_button "Okay! I have read and understand the above warnings."
      response = browser.current_response
    end

    if response.css('div.col-sm-12.content-main > div.user-profile').empty?
      return nil
    end

    user = {}
    
    user[:name] = response.css('span.display-user-username').text
    unless response.css('div.profile-feature-content').empty?
      user[:featured_character] = {}
      user[:featured_character][:name] = response.css('div.thumb-character-name > a.character-name-badge').text
      user[:featured_character][:profile] = response.css('div.thumb-character-name > a.character-name-badge')[0]['href']
      user[:featured_character][:thumbnail] = response.css('div.profile-feature-thumb > div.thumb-image > a.img-thumbnail > img')[0]['src']
      unless response.css('div.profile-feature-gallery').empty?
        user[:featured_character][:images] = response.css('a.th.img-thumbnail > img').map { |img| img['src'] }
      end
    end

    unless response.css('div.profile-characters-content').empty?
      user[:recent_characters] = []
      response.css('div.gallery-row.mini > div').each do |div|
        character = {}
        character[:name] = div.css('div.thumb-caption > span').text
        character[:profile] = div.css('div.thumb-caption > span > a')[0]['href']
        character[:image] = div.css('div.thumb-image > a > img')[0]['src']
        user[:recent_characters] << character
      end
    end

    unless response.css('div.profile-section.user-content').empty?
      user[:description] = ""
      response.css('div.profile-section.user-content')[0].children.each { |child| user[:description] += "#{child.text}\n " }
    end

    # Add comment fetching in the future if user demand is high
    return user
  end
end