namespace :garbage do
  desc "Delete spammy reports and embeds"
  task :reports do
    load 'config/environment.rb'
    still_yet_more = true
    while still_yet_more do
      embeds = Embed.find(:all, :conditions=>'youtube_video_id IS NULL and preview_url IS NULL', :limit=>1000)
      still_yet_more = false unless embeds
      embeds.each do |e|
        puts e.inspect
        Report.destroy(e.report_id)
      end
#      embeds.destroy
    end
  end
end
