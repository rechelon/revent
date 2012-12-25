require 'lib/extensions/string.rb'
FactoryGirl.define do
  factory :attachment do
    filename "test_file"
    content_type "image/jpeg"
    size 50
  end

  factory :blog do
  end

  factory :calendar do
    name "Step It Up" 
    permalink "stepitup"
    site
    theme "default"
    event_start 5.years.ago
    event_end 5.years.from_now
  end

  factory :theme do
    name "sometheme"
    association :site
  end

  factory :theme_element do
    association :theme
    name "body"
    markdown "something"
  end

  factory :category do
  end

  factory :democracy_in_action_object do
  end

  factory :embed do
    html "some html"
  end


  factory :event do |a|
    a.association :calendar, :factory => :calendar
    a.association :host, :factory => :user
    a.name "Step It Up"
    a.location "1 Market St."
    a.description "This event will be awesome."
    a.city "San Francisco"
    a.state "CA"
    a.postal_code "94114"
    a.start(start = Time.now + 2.months)
    a.end start + 2.hours
    a.country_code 'something that will not trigger set_district'
    a.locationless false
  end

  factory :supporter do
    first_name 'John'
    last_name 'Smith'
    email "radcowpenliz+sf_supporter_1@gmail.com"
    street '1370 mission st'
    city 'san francisco'
    state 'CA'
    postal_code '94103'
  end

  factory :site_config do
  end

  factory :politician_invite do
  end

  factory :politician do
  end

  factory :press_link do
  end

  factory :report do
    status Report::PUBLISHED 
    event default_event
    user default_user
    text "this event was dope"
    akismet_params {}
    embed_data({'1' => {:caption => 'video!', :html => '<iframe width="420" height="315" src="http://www.youtube.com/embed/wKrwlgiYn-c" frameborder="0" allowfullscreen></iframe>'}})
    press_link_data({'1' => {:url => 'http://press.link.example.com', :text => 'link!'}})
  end

  factory :role do
    title "admin"
  end

  factory :rsvp do
    
  end

  factory :host do
    hostname "events." + String.random(10) + ".org"
    theme "stepitup"
    site
  end
  
  factory :site do
    association :config, :factory => :site_config
  end

  factory :tagging do
  end

  factory :tag do
  end

  factory :trigger do
  end

  factory :user do
    first_name "Jon"
    last_name "Warnow"
    phone "555-555-5555"
    email "jon." + String.random(8) + "@stepitup.org"  #"jon.warnow@siu.org"
    street "1370 Mission St."
    city "San Francisco"
    state "CA"
    postal_code "94103"
    password "secret" 
    password_confirmation "secret" 
    activated_at 1.day.ago
    association :site
  end

  factory :zip_code do
  end

end

