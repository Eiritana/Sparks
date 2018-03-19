=begin
                      _
 ___ _ __   __ _ _ __| | _____
/ __| '_ \ / _` | '__| |/ / __|
\__ \ |_) | (_| | |  |   <\__ \
|___/ .__/ \__,_|_|  |_|\_\___/
    |_|

an irc bot written by katrin / kiisuke using cinch

=end

require 'cinch'
require 'sequel'

puts "\e[31m"
puts "                      _"
puts " ___ _ __   __ _ _ __| | _____"
puts "/ __| '_ \\ / _` | '__| |/ / __|"
puts "\\__ \\ |_) | (_| | |  |   <\\__ \\"
puts "|___/ .__/ \\__,_|_|  |_|\\_\\___/"
puts "    |_|"
puts ""
puts "an irc bot written by katrin / kiisuke using cinch"
puts "\e[0m"

Dir.glob("plugins/*.rb").each do |f|
    require_relative f
    puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [loader] Loaded: '#{f}'"
end

module Main      
    @@db = Sequel.sqlite "sparks.db"    
    
    configFile = File.read("config.yaml")
    config = YAML.load(configFile)
    
    puts config
    
    @@bot = Cinch::Bot.new do
        configure do |c|
            c.server = config["address"]
            c.port = config["port"]
            c.ssl.use = config["ssl"]
            c.nick = config["nick"]
            c.user = config["user"]
            c.realname = config["real"]
            if config["password"]
                c.password = config["password"]
            end
            c.channels = config["channels"]
            c.messages_per_second = 100000
            c.plugins.plugins = config["plugins"].map { |plugin| 
                plugin.constantize 
            }
            
            [PrivilegesAuto, PrivilegesUp, PrivilegesDown].each { |plugin|
                c.plugins.options[plugin] = {
                    :d2k5_key => config["keys"]["d2k5_key"]
                }
            }
            c.plugins.options[Weather] = {
                :owm_key => config["keys"]["owm_key"]
            }
            c.plugins.options[URLHandler] = {
                :yt_key => config["keys"]["yt_key"],
                :twit_consumer_key => config["keys"]["twit_consumer_key"],
                :twit_consumer_secret => config["keys"]["twit_consumer.secret"],
                :gh_key => config["keys"]["gh_key"],
                :gh_secret => config["keys"]["gh_secret"]
            }
        end
    end
    
    def @@bot.db
        @@db
    end
    
    @@bot.start
end

