class MastodonJob < ApplicationJob
  
  def perform
    Rails.logger.debug "Fetching mastodon via API..."
    begin
      client = Mastodon::REST::Client.new(base_url: 'https://cybre.space', bearer_token: Rails.application.credentials.mastodon[:access_secret])
      account = client.verify_credentials
      toots = client.statuses(account.id, {limit: 40}).select{|t| t.attributes.visibility == 'public'} # max is 40, default is 20
      if toots.empty? || (toots.first.created_at.to_datetime < Time.now-1.week)
        # if I haven't tooted in a while, don't show old shit
        toots = []
      end
    rescue => exception
      ErrorMailer.background_error('caching toots', exception).deliver_now
      toots = []
    end
    Rails.cache.write('toots', toots)
  end
  
end