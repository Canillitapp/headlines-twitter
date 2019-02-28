require 'twitter'
require 'net/http'
require 'json'

stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

stream_client.filter(track: 'canillitapp') do |object|
  begin
    canillitapp_match_regex = /^@canillitapp \/buscar .+/i
    canillitapp_replace_regex = /^@canillitapp \/buscar /i

    if object.is_a?(Twitter::Tweet)
      puts object.text

      if object.text.match(canillitapp_match_regex)
        puts 'matches regex'

        search = object.text.gsub(canillitapp_replace_regex, '')
        uri = URI(URI.escape("https://api.canillitapp.com/search/#{search}"))
        response = Net::HTTP.get(uri)

        json = JSON.parse(response)
        news = json.first

        if news.nil?
          rest_client.update "@#{object.user.screen_name}, no encontré resultados con #{search}"
        else
          title = news['title']
          title = "#{title[0, 100]} (..)" if news['title'].length > 100
          url = "https://www.canillitapp.com/article/#{news['news_id']}?source=twitter"
          tweet = "@#{object.user.screen_name} \"#{title}\" #{url}"

          rest_client.update(tweet, in_reply_to_status_id:object.id)
        end
      end
    end
  rescue => e
    puts e
  end
end
