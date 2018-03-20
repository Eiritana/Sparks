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
            setup_needed = []
            plugin_list = []
            
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
                if defined? plugin_obj.setup_needed
                    setup_needed.push plugin
                else
                    plugin_list << plugin_obj
                    puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [plugin loader] Loaded Plugin: #{plugin}"
                end
            }
            
            c.plugins.plugins = plugin_list
            
            if setup_needed.count > 0
                loaded = Helpers.setup_apis(setup_needed)
                if loaded.count > 0
                    setup_needed.each do |plugin|
                        plugin_obj = Kernel.const_get(plugin)
                        if (plugin_obj.apis & loaded).count > 0
                            c.plugins.plugins.push plugin_obj
                            puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [plugin loader] Setup API and Loaded Plugin: #{plugin}"
                        else
                            puts "#{Time.now.strftime("[%Y/%m/%d %H:%M:%S.%L]")} \e[33m!!\e[0m [plugin loader] Plugin #{plugin} not loaded due to no API keys."                        
                        end
                    end
                end
            end
        end
    end

    @@db = Sequel.sqlite "sparks.db"
    
    def @@bot.db
        @@db
    end
    
    def @@bot.apis
        @@apis
    end
    
    @@bot.start
end

