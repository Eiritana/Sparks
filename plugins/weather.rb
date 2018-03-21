require 'net/http'
require 'json'

class Weather
    include Cinch::Plugin

    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}weather <location> - Gets weather information for <location> from OpenWeatherMap.
    EOF
    
    match /weather (.+)/

    listen_to :connect, method: :setup

    def setup(m)
        unless Helpers.apis.apis.keys.include? "github"
            Helpers.apis.setup_api "orm", Helpers.get_config["keys"]["owm_key"]
        end
    end

    def weather(location)
        if bot.apis["owm"]
            uri = URI("http://api.openweathermap.org/data/2.5/weather?q=#{location}&units=metric&appid=#{bot.apis["owm"]}")
            page = Net::HTTP.get(uri)
            weather = JSON.parse(page)

            if weather != nil and weather["name"] != nil
                location = "#{weather["name"]}, #{weather["sys"]["country"]}"
                celsius = "#{weather["main"]["temp"]}°C"
                description = weather["weather"][0]["main"]
                humidity = "#{weather["main"]["humidity"]}%"
                wind_speed = "#{weather["wind"]["speed"]}km/h"

                return "[\x0311Weather\x03] #{location}, #{celsius}, #{description}, #{humidity}, #{wind_speed}"
            end
            return "[\x0311Weather\x03] Error."
        else
            return "[\x0311Weather\x03] No API key has been provided for this module."
        end
    end

    def execute(m, location)
        m.reply(weather(location))
    end
end
