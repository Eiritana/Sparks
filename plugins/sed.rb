class Sed
    include Cinch::Plugin

    set :help, <<-EOF
[\x0307Help\x03] sed - Does replacements like the unix command \"sed\".
    EOF

    match /(?:(\w+)[,:]?\s?)?s\/([^ \/]*)\/([^ \/]*)(?:\/(\S+))?/, use_prefix: false,  method: :sed

    def sed(m, nick, before, after, groups)
        if nick != nil
            correctee = nick
        else
            corectee = m.user
        end

        corectee_history = Helpers.log.user_chan_get(m.channel.name, corectee)

        if corectee_history.count > 0
            pair = [before, after]

            if groups and groups.include? "i"
                pair[0] = Regexp.new(pair[0])
            else
                pair[0] = Regexp.new(pair[0], Regexp::IGNORECASE)
            end

            if groups and groups.include? "g"
                count = -1
            else
                count = 1
            end

            new_phrase = false
            changed_line = nil
            corectee_history.reverse_each do |line|
                puts line.msg
                changed_line = line.msg.gsub(pair[0], pair[1])
                if changed_line != line
                    puts changed_line
                    new_phrase = true
                    break
                end
            end

            if new_phrase
                if nick != ""
                    m.reply("#{m.user} meant to say: #{changed_line}")
                else
                    m.reply("#{m.user} thought #{nick} meant to say: #{changed_line}")
                end
            end
        end
    end
end