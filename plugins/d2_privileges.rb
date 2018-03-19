def get_priv(username, api_key)
    if api_key
        uri = URI("https://d2k5.com/api/irc/?nick=#{username}&get_profile=1&api=#{api_key}")
        page = Net::HTTP.get(uri)
        xml = Nokogiri::XML.parse(page)
        rank_number = xml.xpath('api/entry/rank').text.to_i
        
        ranks = {
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

class PrivilegesUp
    include Cinch::Plugin
    
    def self.setup_needed
        true
    end
    
    def self.apis
        ["d2k5"]
    end
    
    match "up"
    
    def execute(m)
        set_priv(m, "+", bot.apis["d2k5"])
    end
end

class PrivilegesDown
    include Cinch::Plugin
    
    def self.setup_needed
        true
    end
    
    def self.apis
        ["d2k5"]
    end
    
    match "down"
    
    def execute(m)
        set_priv(m, "-", bot.apis["d2k5"])
    end
end
    
class PrivilegesAuto
    include Cinch::Plugin
    
    def self.setup_needed
        true
    end
    
    def self.apis
        ["d2k5"]
    end
    
    listen_to :connect, method: :connect_handler
    listen_to :join, method: :join_handler
    match /autopriv (on|off)$/
    
    def connect_handler(m)
        bot.db.create_table? :autoprivs do
            primary_key :id
            String :channel_name, unique: true, null: false
            TrueClass :toggle, default: true
        end

        @@autoprivs = bot.db[:autoprivs]
    end
    
    def join_handler(m)
        unless m.user.nick != bot.nick or bot.apis["d2k5"]
            if @@autoprivs.where(:channel_name => m.channel.name).count == 0
                @@autoprivs.insert(:channel_name => m.channel.name, :toggle => true)
            end
            if @@autoprivs.where(:channel_name => m.channel.name).get(:toggle) == true
                set_priv(m, "+", bot.apis["d2k5"])
            end
        end
    end
    
    def execute(m, option)
        unless bot.apis["d2k5"]
            if ["a","o"].include? get_priv(m.user, bot.apis["d2k5"])
                if @@autoprivs.where(:channel_name => m.channel.name).get(:toggle) == true or @@autoprivs.where(:channel_name => m.channel.name).get(:toggle) == false  
                    @@autoprivs.where(:channel_name => m.channel.name).update(:toggle => option == "on")
                    m.reply "[\x0304D2K5\x03] People #{option == "on" ? 'will' : 'won\'t'} automatically be given privileges on join in this channel."
                else
                    @@autoprivs.insert(:channel_name => m.channel.name, :toggle => option == "on")
                    m.reply "[\x0304D2K5\x03] People #{option == "on" ? 'will' : 'won\'t'} automatically be given privileges on join in this channel."
                end
            else
                m.reply "[\x0304D2K5\x03] You are not permitted to use this command."
            end
        else
            return
        end
    end
end
