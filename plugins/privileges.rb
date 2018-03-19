class Privileges
    include Cinch::Plugin
    
    def self.setup_needed
        true
    end
    
    def self.apis
        ["syndbb"]
    end
    
    set :help, <<-EOF
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}up - Sets your mode to your site rank equivalent.
[\x0307Help\x03] #{Helpers.get_config.key?("prefix") ? Config.config["prefix"] : "!"}down - Removes your site rank equivalent mode.
    EOF
    
    match "up", :method => :up
    match "down", :method => :down
    
    def up(m)
        Helpers::Backend.set_priv(m, "+", bot.apis["syndbb"])
    end
    
    def down(m)
        Helpers::Backend.set_priv(m, "-", bot.apis["syndbb"])
    end
end
