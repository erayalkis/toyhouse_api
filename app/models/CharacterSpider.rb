class CharacterSpider < Kimurai::Base
  @name = 'character_spider'
  @engine = :selenium_firefox
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
  }

  def self.instance(url)
    @start_urls = [url]


    character = self.parse!(:parse, url: @start_urls[0])
    return character
  end

  def parse(response, url:, data: {})
    character = {}

    unless response.css('input.btn-success').empty?
      browser.click_button "Okay! I have read and understand the above warnings."
      response = browser.current_response
    end

    character[:name] = response.css('h1.display-4').text
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a')[0].text
    character[:owner][:profile] = response.css('span.display-user a')[0]['href']
    character[:creator] = {}
    character[:creator][:name] = response.css('span.display-user > a')[2].text
    character[:creator][:profile] = response.css('span.display-user a')[2]['href']
    character[:fav_count] = response.css('div.fields-field > dd.col-sm-8')[2].text.strip
    character[:created_at] = response.css('abbr.tooltipster.datetime')[0]['data-original-title']
    character[:created_n_ago] = response.css('abbr.tooltipster.datetime')[0].text

    return character
  end
end