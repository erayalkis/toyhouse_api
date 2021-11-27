class UserSpider < Kimurai::Base
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

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

    if response.css('div.col-sm-12.content-main > div.character-profile').empty?
      return nil
    end

    character[:name] = response.css('h1.display-4').text
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a')[0].text
    character[:owner][:profile] = response.css('span.display-user a')[0]['href']
    character[:creator] = {}
    character[:creator][:name] = response.css('span.display-user > a')[2].text
    character[:creator][:profile] = response.css('span.display-user a')[2]['href']
    character[:description] = ""
    response.css('div.profile-content-content.user-content p').each { |p| character[:description] += "#{p.text}\n" }
    character[:fav_count] = response.css('div.fields-field > dd.col-sm-8')[2].text.strip
    character[:created_n_ago] = response.css('abbr.tooltipster.datetime')[0].text
    from_time = Time.now - character[:created_n_ago][0..1].to_i.days - character[:created_n_ago][9..10].to_i.hours
    character[:created_at] = from_time.strftime("%d %b %Y")
    character[:recent_images] = []
    response.css('li.gallery-item').each { |li| character[:recent_images].push li.css('a.img-thumbnail')[0]["href"] }


    print character[:description].split("\n")
    return character
  end
end