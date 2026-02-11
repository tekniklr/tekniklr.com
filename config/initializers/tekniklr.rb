EMAIL = 'tekniklr@tekniklr.com'
DOMAIN = 'tekniklr.com'
MASTODON = :pdx_social
NUM_FAVS = 6
SIMILAR_THRESHOLD = 50
POST_HISTORY = 3.months # for skeets/etc (mastodon configured natively)
TUMBLR_HISTORY = 18.months
CACHED_ITEMS = [
                  ['tumblr', 'tumblr_expiry'],
                  ['skeets', 'skeet_expiry'],
                  ['toots', 'toot_expiry'],
                  ['gaming', 'gaming_expiry', ['fetch_nintendo', 'fetch_psn', 'fetch_steam', 'fetch_xbox']],
                  ['letterboxd', 'letterboxd_expiry'],
                  ['goodreads', 'goodreads_expiry'],
                  ['lastfm', 'lastfm_expiry']
                ]