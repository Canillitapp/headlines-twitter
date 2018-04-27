require 'net/http'
require 'json'
require 'date'
require 'twitter'
require 'rufus-scheduler'

def generate_news_tweets
  tweets = []

  today = DateTime.now.new_offset('-03:00')
  today_string = today.strftime '%Y-%m-%d'
  url = "#{ENV['CANILLITAPP_API']}/trending/#{today_string}/3"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  json = JSON.parse(response)

  # Resumen
  tweets << "Los temas destacados del momento son: #{json['keywords'].join(', ')} https://www.canillitapp.com/#{today_string}"

  # Detalle
  json['news'].keys.take(3).each_with_index do |k, i|
    text = "##{k}: #{json['news'][k][0]['title']}"
    news_url = "https://www.canillitapp.com/article/#{json['news'][k][0]['news_id']}?source=twitter"
    tweets << "#{text[0,230]} #{news_url}"
  end

  tweets
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

scheduler = Rufus::Scheduler.new

scheduler.cron '0 10,18,20,21 * * *' do
  generate_news_tweets.each do |t|
    client.update t
    puts t
  end
end

scheduler.join

