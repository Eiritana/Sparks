module Social
    class GitHub
        include Cinch::Plugin

        def self.setup_needed
            true
        end
        
        def self.apis
            ["github"]
        end

        match %r{http(?:s)?:\/\/(?:(www|gist).)?github.com\/([^ /?]+)(?:\/)?([^ /?]+)?}, use_prefix: false, method: :github_url

        def github_url(m, subdomain, user_name, repo_name)
            if subdomain != "gist"
                if repo_name != nil
                    repos = bot.apis["github"]::Client::Repos.new

                    repo = repos.get user: user_name, repo: repo_name
                    m.reply "[GitHub] #{repo.full_name} - \"#{repo.description}\" - Last Commit: #{Time.parse(repo.pushed_at).strftime("%F %R")} - ↻#{repo.forks_count} ⭐#{repo.stargazers_count} - ⚠️#{repo.open_issues_count}"
                elsif user_name != nil
                    users = bot.apis["github"]::Client::Users.new
                    user = users.get user: user_name
                    
                    if user.location != ""
                        location = " - Location: #{user.location}"
                    else
                        location = ""
                    end
                    if user.bio != ""
                        bio = " - \"#{user.bio}\""
                    else
                        bio = ""
                    end
                    
                    m.reply "[GitHub] #{user.name} (#{user.login})#{location} #{bio} - Repos: #{user.public_repos} - Gists: #{user.public_gists}"
                end
            else
                gists = bot.apis["github"]::Client::Gists.new
                gist = gists.get id: repo_name
                if gist.description != ""
                    description = " - \"#{gist.description}\""
                end
                m.reply "[GitHub/Gists] #{gist.owner.login}/#{gist.files.to_hash.values[0]["filename"]}#{description} - Last Update: #{Time.parse(gist.updated_at).strftime("%F %R")} - \"#{gist.files.to_hash.values[0]["content"]}\""
            end
        end
    end
end