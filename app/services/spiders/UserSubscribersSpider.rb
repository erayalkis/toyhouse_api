class Spiders::UserSubscribersSpider < Spiders::ToyhouseSpider
  @name = 'user_subscribers_spider'

  def parse(response, url:, data: {})
    pagination_wrapper = response.css("div.pagination-wrapper")
    subscribers = request_to :parse_subscribers_page, url: url

    if data[:subscribers]
      puts "adding new subscribers"
      data[:subscribers] += subscribers
    else
      puts "creating new subs array"
      data[:subscribers] = subscribers
    end

    next_page_wrapper = pagination_wrapper.empty? ? nil : pagination_wrapper.css("li.page-item")[-1]
    next_page = next_page_wrapper.nil? ? nil : next_page_wrapper.css(".page-link")[0]['href']

    if pagination_wrapper.length.zero? || next_page.nil?
      return data[:subscribers]
    end

    request_to :parse, url: next_page, data: data.merge(subscribers: data[:subscribers])
  end

  def parse_subscribers_page(response, url:, data: {})
    users_arr = []
    response.css("div.col-4").each do |col|
      user = {}
      user[:image] = col.css("div.mb-1 img.mw-100")[0]['src']
      user[:name] = col.css("a.user-name-badge").text.strip
      users_arr << user
    end

    users_arr
  end
end