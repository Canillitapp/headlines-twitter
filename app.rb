require 'net/http'
require 'json'
require 'chatterbot/dsl'

use_streaming

replies do |tweet|
  begin
    next unless tweet.text =~ /^@canillitapp buscar /

    search = tweet.text.gsub(/^@canillitapp buscar /, '')
    uri = URI(URI.escape("http://api.canillitapp.com/search/#{search}"))
    response = Net::HTTP.get(uri)

    json = JSON.parse(response)
    news = json.first

    src = "#USER# No encontré resultados con #{search} ^B"
    unless news.nil?
      title = news['title'].length > 60 ? "#{news['title'][0, 60]} (..)" : news['title']
      src = "#USER# '#{title}' #{news['url']} ^B"
    end

    reply src, tweet
  rescue => e
    puts e
  end
end
