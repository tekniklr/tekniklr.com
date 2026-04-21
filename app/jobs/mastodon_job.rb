class MastodonJob < ApplicationJob
  
  def perform
    defer_retry('mastodon', 3) { get_mastodon }
  end

  private

  def get_mastodon
    Rails.logger.debug "Fetching mastodon via API..."
    toots = []
    client = Mastodon::REST::Client.new(base_url: Rails.application.credentials.mastodon[MASTODON][:url], bearer_token: Rails.application.credentials.mastodon[MASTODON][:access_token])
    account = client.verify_credentials
    toots = client.statuses(account.id, {limit: 40}).select{|t| t.attributes.visibility == 'public'} # max is 40, default is 20
    if toots.empty? || (toots.first.created_at.to_datetime < Time.now-1.week)
      # if I haven't tooted in a while, don't show old shit
      toots = []
    end
    unless toots.blank?
      Rails.cache.write('toots', toots)
    end
  end
  
end