class Spiders::UserSubscribersSpider < Spiders::ToyhouseSpider
  @name = 'user_subscribers_spider'

  def parse(response, url:, data: {})
    subscribers = []
    paginated = response.css("div.pagination-wrapper").length > 0

    if response.css("div.col-4").empty?
      return @subscribers
    end

    unless paginated
      data = request_to :parse_subscribers_page, url: url
      return data
    end
    
    request_to :parse_subscribers_page, url: url, data: data.merge(subscribers: subscribers)
    # request_to :parse, url: next_page, data: { subscribers: subscribers }
  end

  def parse_subscribers_page(response, url:, data: {})
    temp_arr = []
    response.css("div.col-4").each do |col|
      user = {}
      user[:image] = col.css("div.mb-1 img.mw-100")[0]['src']
      user[:name] = col.css("a.user-name-badge").text.strip
      temp_arr << user
    end

    return temp_arr
  end
end