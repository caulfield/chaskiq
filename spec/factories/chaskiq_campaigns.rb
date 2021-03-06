# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :chaskiq_campaign, :class => 'Chaskiq::Campaign' do
    name "some Campaign"
    subject "Hello"
    from_name "Me"
    from_email "me@me.com"
    reply_email "reply-me@me.com"
    #plain_content "hi this is the plain content"
    #html_content "<h1>hi this is htmlcontent </h1>"
    #query_string "opt=1&out=2"
    #scheduled_at "2015-03-17 23:10:06"
    #timezone "utc-4"
    #recipients_count 1
    #sent false
    #opens_count 1
    #clicks_count 1
    #parent nil
  end
end
