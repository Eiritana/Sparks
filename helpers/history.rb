module Helpers
    class HistoryLog
        attr_reader :logs

        def initialize
            @@logs = {}
        end

        def add(channel, nick, msg)
            (@@logs[channel.name] ||= []) << HistoryEntry.new(nick, msg)
            if @@logs[channel.name].count > 30
                @@logs[channel.name] = @@logs[channel.name][-30..-1]
            end
        end

        def chan_get(channel)
            return @@logs[channel]
        end

        def user_chan_get(channel, user)
            channel_logs = chan_get(channel)
            return channel_logs.select { |log| log.nick == user }
        end
    end

    class HistoryEntry
        attr_reader :nick, :msg, :timestamp

        def initialize(nick, msg)
            @nick = nick
            @msg = msg
            @timestamp = Time.now.to_i
        end
    end

    @@log = HistoryLog.new

    def log
        @@log
    end

    module_function :log
end