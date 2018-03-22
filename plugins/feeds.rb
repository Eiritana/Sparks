require 'net/http'
require 'nokogiri'

class Feeds
    include Cinch::Plugin
    
    def self.required_config
        ["settings:syndbb_url"]
    end

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
        Feed.new("Post", "#{Helpers.get_config["settings"]["syndbb_url"]}/feed/posts/xml"),
        Feed.new("Thread", "#{Helpers.get_config["settings"]["syndbb_url"]}/feed/threads/xml")
    ]

    @@last_update = Time.new.to_i
    
    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}feed <feed> - Gets data from a feed. Feeds: #{@@feeds.map { |feed| feed.name }.join(", ")}.
    EOF
    
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
                    feed.last_post = "[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] New #{feed.name}: #{request.xpath('title').text} - #{request.xpath('link').text}"
                    Channel("#d2k5").send(feed.last_post)
                    @@last_update = Time.new.to_i
                else
                    if feed.last_post != "[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] New #{feed.name}: #{posts[-1].xpath('title').text} - #{posts[-1].xpath('link').text}"
                        feed.last_post = "[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] New #{feed.name}: #{posts[-1].xpath('title').text} - #{posts[-1].xpath('link').text}"
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
            Target(m.target).send(feed[0].last_post)
        else
            feed_reader
            Target(m.target).send(feed[0].last_post)
        end
    end
end
