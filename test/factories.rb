FactoryBot.define do

  factory :experience do |e|
    e.sequence(:title) {|n| "Position title #{n}"}
    e.affiliation 'Hall of Records'
    e.start_date '2001-01-31'.to_date  
  end

  factory :facet do |f|
    f.sequence(:name) {|n| "Facet #{n}"}
    f.slug "facet_perm"
    f.value "stuff, stuff, and more stuff"
  end

  factory :favorite do |f|
    f.sequence(:favorite_type) {|n| "Favorite type #{n}"}
    f.sort 1
  end

  factory :favorite_thing do |ft|
    ft.sequence(:thing) {|n| "Thing #{n}"}
    ft.link 'http://google.com'
    ft.sort 1
    ft.favorite {|f| f.association(:favorite)}
  end

  factory :link do |l|
    l.sequence(:name) {|n| "Link #{n}"}
    l.url 'http://google.com'
    l.visible 1
    l.icon_file_name    { 'icon.png' }
    l.icon_content_type { 'image/png' }
    l.icon_file_size    { 1024 }
  end

  factory :tabletop_game do |t|
    t.sequence(:name) {|n| "Tabletop game #{n}"}
  end

  factory :recent_game do |g|
    g.sequence(:name) {|n| "Game #{n}"}
    g.platform 'Wii U'
    g.url 'http://google.com'
    g.started_playing Date.yesterday
  end

  factory :user do |u|
    u.sequence(:name) {|n| "User: #{n}"}
    u.provider 'twitter'
    u.uid '12345'
    u.handle 'tekniklr'
  end

end
