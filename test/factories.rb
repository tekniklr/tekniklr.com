FactoryBot.define do

  factory :experience do
    sequence(:title) {|n| "Position title #{n}"}
    affiliation      { 'Hall of Records' }
    start_date       { '2001-01-31'.to_date }
  end

  factory :facet do
    sequence(:name) {|n| "Facet #{n}"}
    sequence(:slug) {|s| "facet_#{s}"}
    value           { "stuff, stuff, and more stuff" }
  end

  factory :favorite do
    sequence(:favorite_type) {|n| "Favorite type #{n}"}
    sort                     { 1 }
  end

  factory :favorite_thing do |ft|
    sequence(:thing) {|n| "Thing #{n}"}
    link             { 'http://google.com' }
    sort             { 1 }
    favorite         {|f| f.association(:favorite)}
  end

  factory :link do
    sequence(:name)   {|n| "Link #{n}"}
    url               { 'http://google.com' }
    visible           { 1 }
    icon_file_name    { 'icon.png' }
    icon_content_type { 'image/png' }
    icon_file_size    { 1024 }
  end

  factory :tabletop_game do
    sequence(:name) {|n| "Tabletop game #{n}"}
  end

  factory :recent_game do
    sequence(:name) {|n| "Game #{n}"}
    platform        { 'Wii U' }
    url             { 'http://google.com' }
    started_playing { Date.yesterday }
  end

  factory :user do
    sequence(:name) {|n| "User: #{n}"}
    provider        { 'google_oauth2' }
    uid             { '12345' }
    handle          { 'tekniklr' }
  end

end
