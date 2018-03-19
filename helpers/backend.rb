module Helpers
    module Backend
        def get_priv(username, api_key)
            if api_key
                uri = URI("#{Helpers.get_config["settings"]["syndbb_url"]}/api/irc/?nick=#{username}&get_profile=1&api=#{api_key}")
                page = Net::HTTP.get(uri)
                xml = Nokogiri::XML.parse(page)
                rank_number = xml.xpath('api/entry/rank').text.to_i
                
                ranks = {
                    999 => "a",
                    900 => "a",
                    500 => "o",
                    100 => "h",
                    50 => "v",
                    0 => "v"
                }
                
                if rank_number != nil
                    return ranks[rank_number]
                else
                    return false
                end
            else
                return false
            end
        end

        def set_priv(m, flag, api_key)
            priv = get_priv(m.user, api_key)
            
            if priv != false
                m.bot.irc.send("MODE #{m.channel} #{flag}#{priv} #{m.user.nick}")
            else
                debug "User does not exist in the backend or the API key has not been provided."
            end
        end
        
        def get_profile(username, api_key)
            uri = URI("#{Helpers.get_config["settings"]["syndbb_url"]}/api/irc/?nick=#{username}&get_profile=1&api=#{api_key}")
            page = Net::HTTP.get(uri)
            xml = Nokogiri::XML.parse(page)
            base = xml.xpath('api/entry')
    
            ranks = {
                999 => "!",
                900 => "&",
                500 => "@",
                100 => "%",
                50 => "+",
                0 => "+"
            }

            gender_icons = {
                "male" => "♂ ",
                "female" => "♀ ",
                "agender" => "⚲ "
            }

            if base
                if base.xpath('gender').text != ""
                    gender = " - #{gender_icons[base.xpath('gender').text.downcase]}#{base.xpath('gender').text}"
                end
                if base.xpath('location').text != ""
                    location = " - #{base.xpath('location').text}"
                end
                if base.xpath('occupation').text != ""
                    occupation = " - #{base.xpath('occupation').text}"
                end

                return "#{ranks[base.xpath('rank').text.to_i]}#{base.xpath('name').text} - #{Time.at(base.xpath('join_date').text.to_i).strftime("%F %R")} - Ð#{base.xpath('points').text}#{gender}#{location}#{occupation}"
            end
        end

        module_function :get_priv, :set_priv, :get_profile
    end
end
