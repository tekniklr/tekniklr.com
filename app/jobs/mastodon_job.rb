class MastodonJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching mastodon via API..."
    begin
      client = Mastodon::REST::Client.new(base_url: 'https://cybre.space', bearer_token: Rails.application.credentials.mastodon[:access_secret])
      account = client.verify_credentials
      toots = client.statuses(account.id, {limit: 69}).select{|t| t.attributes.visibility == 'public'}
      if toots.first.created_at.to_datetime < Time.now-1.week
        # if I haven't tooted in a while, maybe I've wandered off from
        # mastodon again? it's happened before. I hope this death of twitter
        # thing sticks, one day
        toots = []
      end
    rescue
      toots = []
    end
    Rails.cache.write('toots', toots)
  end
  
end