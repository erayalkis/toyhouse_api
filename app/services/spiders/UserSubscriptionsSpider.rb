class Spiders::UserSubscriptionsSpider < Spiders::ToyhouseSpider
  @name = 'user_subscriptions_spider'

  def parse(response, url:, data: {})
    pagination_wrapper = response.css("div.pagination-wrapper")
    subscriptions = request_to :parse_subscriptions_page, url: url

    if data[:subscriptions]
      puts "adding new subscriptions"
      data[:subscriptions] += subscriptions
    else
      puts "creating new subs array"
      data[:subscriptions] = subscriptions
    end

    next_page_wrapper = pagination_wrapper.empty? ? nil : pagination_wrapper.css("li.page-item")[-1]
    next_page = next_page_wrapper.nil? ? nil : next_page_wrapper.css(".page-link")[0]['href']

    if pagination_wrapper.length.zero? || next_page.nil?
      return data[:subscriptions]
    end

    request_to :parse, url: next_page, data: data.merge(subscriptions: data[:subscriptions])
  end

  def parse_subscriptions_page(response, url:, data: {})
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