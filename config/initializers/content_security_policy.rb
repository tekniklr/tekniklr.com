Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data, 'https://fonts.gstatic.com'
    policy.img_src     :self, :https, :data, 'https://lastfm.freetls.fastly.net', 'https://pbs.twimg.com', 'https://i.gr-assets.com', 'https://*.media.tumblr.com', 'https://gravatar.com/avatar/*'
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, 'https://fonts.googleapis.com'
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap and inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)

  # to only log but still allow things through
  #config.content_security_policy_report_only = true
end
