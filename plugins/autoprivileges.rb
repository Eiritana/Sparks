class AutoPrivileges
    include Cinch::Plugin
    
    def self.setup_needed
        true
    end
    
    def self.apis
        ["syndbb"]
    end
    
    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}autopriv <on|off> - Requires site operator or above. Toggles whether a channel has automatically set privileges.
    EOF
    
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
        unless m.user.nick != bot.nick or bot.apis["syndbb"]
            if @@autoprivs.where(:channel_name => m.channel.name).count == 0
                @@autoprivs.insert(:channel_name => m.channel.name, :toggle => true)
            end
            if @@autoprivs.where(:channel_name => m.channel.name).get(:toggle) == true
                Helpers::Backend.set_priv(m, "+", bot.apis["syndbb"])
            end
        end
    end
    
    def execute(m, option)
        unless bot.apis["syndbb"]
            if ["a","o"].include? Helpers::Backend.get_priv(m.user, bot.apis["syndbb"])
                if @@autoprivs.where(:channel_name => m.channel.name).get(:toggle) == true or @@autoprivs.where(:channel_name => m.channel.name).get(:toggle) == false  
                    @@autoprivs.where(:channel_name => m.channel.name).update(:toggle => option == "on")
                    m.reply "[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] People #{option == "on" ? 'will' : 'won\'t'} automatically be given privileges on join in this channel."
                else
                    @@autoprivs.insert(:channel_name => m.channel.name, :toggle => option == "on")
                    m.reply "[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] People #{option == "on" ? 'will' : 'won\'t'} automatically be given privileges on join in this channel."
                end
            else
                m.reply "[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] You are not permitted to use this command."
            end
        else
            return
        end
    end
end
