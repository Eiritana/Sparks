class History 
    include Cinch::Plugin

    match /(.*)/, use_prefix: false, method: :history_add

    def history_add(m)
        unless m.user == bot.nick
            unless /(?:(\w+)[,:]?\s?)?s\/([^ \/]*)\/([^ \/]*)(?:\/(\S+))?/.match(m.params[1])
                Helpers.log.add(m.channel, m.user, m.params[1])
            end
        end
    end
end
