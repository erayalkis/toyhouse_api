class CharacterGallerySpider < Kimurai::Base
   
  @name = 'character_gallery_spider'
  @engine = :mechanize
  @config = {
    user_agent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36",
    cookies: [{name: "laravel_session", value: "eyJpdiI6InFPK1dKTS9ReVJuRnBDR1Zzcjdsa2c9PSIsInZhbHVlIjoiTE9sZmdxUkZZbzdEbVdRbUxRZkpwY3V2L3JXd2kwN0h6TkdqR1hoSWl6dDRXREplaGFRNWs4RjZhOFEyZCt0MzVTSVM1clpQRTJzZ2lGSU9WMXZzNEJ2d3U1VDdHSHVMdzFWeUJxTTgzV2R3dTNydlFJaTMwMjZQR0VsbldkdG4iLCJtYWMiOiJiOGEyODU2ZDA0MGRiMmFkMGMxOGNlZmUxZTM4NGI5YTliZmNjZmQzNDAyNTNmOTBkMGRjYmQ3OGZkODhmNTc2In0%3D", domain: "toyhou.se"}]
  }
  @auths = nil

  def self.instance(url, auths)
    @start_urls = [url]
    @auths = auths

    gallery = self.parse!(:parse, url: @start_urls[0], data: {auths: @auths})
    return gallery
  end

  def parse(response, url:, data: {})
    character = {}
    character[:owner] = {}
    character[:owner][:name] = response.css('span.display-user > a > span.display-user-username').text

    if response.css('ul.magnific-gallery').empty?
      return { msg: 'Character has no images or character profile is locked!', status: 422 }
    end

    unless response.css('i.fa.fa-unlock-alt').empty?
      if data[:auths].include?(character[:owner][:name])
        puts "User is authorized"
      else
        return { msg: 'Character is locked and/or you\'re unauthorized to see their profile!', status: 422 }
      end
    end


    character[:owner][:link] = response.css('span.display-user > a')[0]['href']
    character[:name] = response.css('li.character-name').text.strip
    character[:gallery] = []
    response.css('div.thumb-image > a').each { |a| character[:gallery] << a['href'] }
    return character
  end
end