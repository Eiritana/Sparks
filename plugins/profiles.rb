class Profiles
    include Cinch::Plugin
    
    def self.setup_needed
        true
    end
    
    def self.apis
        ["syndbb"]
    end
    
    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}profile - Fetches your own profile.
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}profile <user> - Fetches <user>'s profile.
    EOF
    
    match /profile(?:\s(.*))?/, :method => :profile_other

    def profile_other(m, username)
        if username
            m.reply("[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] #{Helpers::Backend.get_profile(username, bot.apis["syndbb"])}")
        else
            m.reply("[\x0304#{Helpers.get_config["settings"]["syndbb_name"]}\x03] #{Helpers::Backend.get_profile(m.user, bot.apis["syndbb"])}")
        end
    end
end
