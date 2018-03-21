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
require 'yaml'

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

require_relative 'helpers/config'
require_relative 'helpers/history'
require_relative 'helpers/api_setup'
require_relative 'helpers/backend'

Dir.glob("plugins/*.rb").each do |f|
    require_relative f
    puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [file loader] Loaded: '#{f}'"
end

module Main    
    @@bot = Cinch::Bot.new do
        configure do |c|         
            c.server = @@config["address"]
            c.port = @@config["port"]
            c.ssl.use = @@config["ssl"]
            c.nick = @@config["nick"]
            c.user = @@config["user"]
            c.realname = @@config["real"]
            if @@config["password"]
                c.password = @@config["password"]
            end
            c.channels = @@config["channels"]
            c.messages_per_second = 100000
            
            @@config["plugins"].each { |plugin| 
                plugin_obj = Kernel.const_get(plugin)
                c.plugins.plugins << plugin_obj
                puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [plugin loader] Loaded Plugin: #{plugin}"
            }
        end
    end

    @@db = Sequel.sqlite "sparks.db"
    
    def @@bot.db
        @@db
    end
    
    def @@bot.apis
        @@apis.apis
    end
    
    @@bot.start
end

