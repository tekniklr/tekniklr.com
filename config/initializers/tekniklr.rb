EMAIL = 'tekniklr@tekniklr.com'
DOMAIN = 'tekniklr.com'
MASTODON = :pdx_social
NUM_FAVS = 6
SIMILAR_THRESHOLD = 50
POST_HISTORY = 3.months # for skeets/etc (mastodon configured natively)
TUMBLR_HISTORY = 18.months
CACHED_ITEMS = [
                  ['tumblr', 'tumblr_expiry', ['failed_fetching_tumblr']],
                  ['skeets', 'skeet_expiry', ['failed_fetching_bsky']],
                  ['toots', 'toot_expiry', ['failed_fetching_mastodon']],
                  ['gaming', 'gaming_expiry', ['failed_fetching_nintendo', 'failed_fetching_psn', 'failed_fetching_steam', 'failed_fetching_xbox']],
                  ['letterboxd', 'letterboxd_expiry', ['failed_fetching_letterboxd']],
                  ['goodreads', 'goodreads_expiry', ['failed_fetching_goodreads']],
                  ['lastfm', 'lastfm_expiry', ['failed_fetching_lastfm']]
                ]