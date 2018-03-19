# Sparks

An IRC bot written in Ruby, using Cinch.

## Example Config

```yaml
nick: Sparks
user: sparks
real: Jodene Sparks
address: localhost
port: 6667
ssl: No

channels:
    - "#bottest"

plugins: 
    - Weather
    - URLs
    - Reminders
    - Privileges
    - AutoPrivileges
    - Feeds
    - Help
    
settings:
    syndbb_url: No

keys:
    syndbb_key: No
    owm_key: No
    yt_key: No
    twit_consumer_key: No
    twit_consumer_secret: No
    gh_key: No
    gh_secret: No
```

## Plugins

* SynDBB Integration
	* Feed Reader pulls in newest threads and posts
	* Privileges from the API
		* Automatic, toggleable per channel and persistent.
			* Persistency facilitated by the SQLite database.
		* Manual with `!up` and `!down`.

* Reminders
	* Triggered by something like `!in 5 hours 4 minutes test`.
	* Persistent, stored in the SQLite database.

* URL Handling
	* YouTube
		* Videos
	* GitHub
		* Repositories
		* Profiles
		* Gists
	* Twitter
		* Profiles
		* Statuses
	* Fallback

* Weather
	* Provided by OpenWeatherMap.
