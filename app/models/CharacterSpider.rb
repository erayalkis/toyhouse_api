class CharacterSpider < Kimurai::Base
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  @name = 'character_spider'
  @engine = :mechanize
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

    if response.css('div.col-sm-12.content-main > div.character-profile').empty?
      return nil
    end

    character[:name] = response.css('h1.display-4').text
    character[:creator] = {}
    character[:creator][:name] = response.css('dd.field-value.col-sm-8')[1].text
    character[:creator][:profile] = response.css('dd.field-value.col-sm-8 a')[0]['href']
    character[:creator][:profile] = nil if response.css('dd.field-value.col-sm-8')[1].children.length == 1
    character[:owner] = {}
    character[:owner][:name] = response.css('div.profile-name-info > h2 > .display-user > a').text
    character[:owner][:profile] = response.css('div.profile-name-info > h2 > .display-user > a')[0]['href']
    character[:description] = ""
    if response.css('div.profile-content-content.user-content').children.length == 1
      character[:description] = response.css('div.profile-content-content.user-content').text 
    else
      response.css('div.profile-content-content.user-content').children.each do |ele|
        unless ele.children.empty?
          ele.children.each { |ele| character[:description] += "#{ele.text}\n" if ele.name != 'br' }
        else
          character[:description] += "#{ele.text}\n" if ele.children.length > 1
        end    
      end
    end
    character[:fav_count] = response.css('div.fields-field > dd.col-sm-8')[2].text.strip
    character[:created_n_ago] = response.css('abbr.tooltipster.datetime')[0].text
    character[:created_at] = response.css('dl.fields > div.row.fields-field > dd.field-value.col-sm-8 > abbr')[0]['title']
    character[:tags] = []
    response.css('div.profile-tags-content a').each { |a| character[:tags] << a.text }
    character[:recent_images] = []
    response.css('li.gallery-item').each { |li| character[:recent_images].push li.css('a.img-thumbnail')[0]["href"] }

    # Add comment fetching in the future if user demand is high
    return character
  end
end