require 'github_api'

module URL
    class GitHubAPI
        include Cinch::Plugin

        def self.regex
            %r{http(?:s)?:\/\/(?:(www|gist).)?github.com\/([^ /?]+)(?:\/)?([^ /?]+)?(?:\/)?(?:(issues|pulls|commit)\/([^ ?\#\/]+))?}
        end

        set :help, <<-EOF
[\x0307Help\x03] GitHub - This module supports URL parsing for repositories, users, issues, commits and pulls.
        EOF
            
        match self.regex, use_prefix: false, method: :github_url
        listen_to :connect, method: :setup

        def setup(m)
            unless Helpers.apis.apis.keys.include? "github"
                Helpers.apis.setup_api "github", Github.new do |c|
                    c.client_id = Helpers.get_config["keys"]["gh_key"]
                    c.client_secret = Helpers.get_config["keys"]["gh_secret"]
                  end
            end
        end

        def github_url(m, subdomain, user_name, repo_name, subquery, subquery_id)
            if subdomain != "gist"
                if repo_name != nil
                    if subquery != nil
                        if subquery == "issues"
                            issue = Github.issues.get user_name, repo_name, subquery_id

                            if issue.assignees.count > 1
                                assignees = " - Assignees: #{issue.assignees.map {|assignee| assignee.login}.join(", ")}"
                            elsif issue.assignees.count == 1
                                assignees = " - Assignee: #{issue.assignees.map {|assignee| assignee.login}.join(", ")}"
                            end

                            if Time.parse(issue.updated_at) != Time.parse(issue.created_at)
                                time = "Created at: #{Time.parse(issue.created_at).strftime("%F %R")} - Updated at: #{Time.parse(issue.updated_at).strftime("%F %R")}"
                            else
                                time = "Created at: #{Time.parse(issue.created_at).strftime("%F %R")}"
                            end

                            m.reply "[GitHub/Issue] #{user_name}/#{repo_name} - \"#{issue.title}\" by #{issue.user.login} - #{time} - State: #{issue.state == "open" ? "\x0303Open\x03" : "\x0304Closed\x03"} & #{issue.locked ? "\x0304Locked\x03" : "\x0303Unlocked\x03"}#{assignees}"
                        elsif subquery == "commit"
                            commit = Github.repos.commits.get user: user_name, repo: repo_name, sha: subquery_id
                            puts commit

                            m.reply "[GitHub/Commit] \"#{commit.commit.message}\" by #{commit.commit.committer.name} (#{commit.committer.login}) - Committed: #{Time.parse(commit.commit.committer.date).strftime("%F %R")} - #{commit.stats.total} (\x0303+#{commit.stats.additions}\x03/\x0304-#{commit.stats.deletions}\x03) - #{commit.commit.verification.verified ? "\x0303Signed\x03" : "\x0304Unsigned\x03"}"
                        elsif subquery == "pulls"
                            pull = Github.pull_requests.get user_name, repo_name, subquery_id

                            if Time.parse(pull.updated_at) != Time.parse(pull.created_at)
                                time = "Created at: #{Time.parse(pull.created_at).strftime("%F %R")} - Updated at: #{Time.parse(pull.updated_at).strftime("%F %R")}"
                            else
                                time = "Created at: #{Time.parse(pull.created_at).strftime("%F %R")}"
                            end
                            
                            m.reply "[GitHub/Pull] #{user_name}/#{repo_name} - \"#{pull.title}\" by #{pull.user.login} - #{time} - State: #{pull.state == "open" ? "\x0303Open\x03" : "\x0304Closed\x03"} & #{pull.locked ? "\x0304Locked\x03" : "\x0303Unlocked\x03"}#{assignees}"                            
                        end
                    else
                        repos = Github::Client::Repos.new

                        repo = repos.get user: user_name, repo: repo_name

                        puts repo
                        m.reply "[GitHub/Repo] #{repo.full_name} - \"#{repo.description}\" - Last Commit: #{Time.parse(repo.pushed_at).strftime("%F %R")} - ↻#{repo.forks_count} ⭐#{repo.stargazers_count} - ⚠️#{repo.open_issues_count}"
                    end
                elsif user_name != nil
                    users = Github::Client::Users.new
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
                    
                    m.reply "[GitHub/User] #{user.name} (#{user.login})#{location} #{bio} - Repos: #{user.public_repos} - Gists: #{user.public_gists}"
                end
            else
                gists = Github::Client::Gists.new
                gist = gists.get id: repo_name
                if gist.description != ""
                    description = " - \"#{gist.description}\""
                end
                m.reply "[GitHub/Gist] #{gist.owner.login}/#{gist.files.to_hash.values[0]["filename"]}#{description} - Last Update: #{Time.parse(gist.updated_at).strftime("%F %R")} - \"#{gist.files.to_hash.values[0]["content"]}\""
            end
        end
    end
end