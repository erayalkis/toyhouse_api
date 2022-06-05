class Spiders::CharacterSpider < Spiders::ToyhouseSpider
  @name = 'character_spider'

  def parse(response, url:, data: {})
    character = {}

    if response.css('div.col-sm-12.content-main > div.character-profile').empty?
      return nil
    end

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths].include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end

    character[:name] = response.css('h1.display-4').text.strip
    character[:creator] = {}
    character[:creator][:name] = response.css('dd.field-value.col-sm-8')[1].text.strip
    character[:creator][:link] = response.css('dd.field-value.col-sm-8 a')[0]['href']
    character[:creator][:link] = nil if response.css('dd.field-value.col-sm-8')[1].children.length == 1
    character[:owner] = {}
    character[:owner][:name] = response.css('div.profile-name-info > h2 > .display-user > a').text.strip
    character[:owner][:link] = response.css('div.profile-name-info > h2 > .display-user > a')[0]['href']
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