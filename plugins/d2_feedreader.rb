require 'net/http'
require 'nokogiri'

class FeedReader
    include Cinch::Plugin
    
    class Feed
        attr_reader :name, :url
        attr_accessor :last_post
        
        def initialize(name, url)
            @name = name
            @url = url
            @last_post = ""
        end
    end
    
    @@feeds = [
        Feed.new("Post", "https://d2k5.com/feed/posts/xml"),
        Feed.new("Thread", "https://d2k5.com/feed/threads/xml")
    ]

    @@last_update = Time.new.to_i
    
    timer 300, method: :feed_reader
    match /feed (.+)/
    
    def feed_reader
        info "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [feed reader] executed."
        @@feeds.each do |feed|
            uri = URI(feed.url)
            page = Net::HTTP.get(uri)
            list = Nokogiri::XML.parse(page)
            posts = list.xpath("channel/item").reverse
            
            posts.each do |request|
                if @@last_update < request.xpath('pubDate').text.to_i
                    feed.last_post = "[\x0304D2K5\x03] New #{feed.name}: #{request.xpath('title').text} - #{request.xpath('link').text}"
                    Channel("#d2k5").send(feed.last_post)
                    @@last_update = Time.new.to_i
                else
                    if feed.last_post != "[\x0304D2K5\x03] New #{feed.name}: #{posts[-1].xpath('title').text} - #{posts[-1].xpath('link').text}"
                        feed.last_post = "[\x0304D2K5\x03] New #{feed.name}: #{posts[-1].xpath('title').text} - #{posts[-1].xpath('link').text}"
                        puts feed.last_post
                        break
                    end
                end
            end
        end
        info "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [feed reader] finished execution."
    end

    def execute(m, feedName)
        feed = @@feeds.select { |temp_feed| temp_feed.name == feedName.capitalize }
        
        
        if feed[0].last_post != ""
            Channel("#d2k5").send(feed[0].last_post)
        else
            feed_reader
            Channel("#d2k5").send(feed[0].last_post)
        end
    end
end
