EMAIL = 'tekniklr@tekniklr.com'
DOMAIN = 'tekniklr.com'
MASTODON = :pdx_social
NUM_FAVS = 6
SIMILAR_THRESHOLD = 50
POST_HISTORY = 3.months # for skeets/etc (mastodon configured natively)
TUMBLR_HISTORY = 18.months
CACHED_ITEMS = [
                  ['tumblr', 'tumblr_expiry', ['fetch_tumblr']],
                  ['skeets', 'skeet_expiry', ['fetch_bsky']],
                  ['toots', 'toot_expiry', ['fetch_mastodon']],
                  ['gaming', 'gaming_expiry', ['fetch_nintendo', 'fetch_psn', 'fetch_steam', 'fetch_xbox']],
                  ['letterboxd', 'letterboxd_expiry', ['fetch_letterboxd']],
                  ['goodreads', 'goodreads_expiry', ['fetch_goodreads']],
                  ['lastfm', 'lastfm_expiry', ['fetch_lastfm']]
                ]