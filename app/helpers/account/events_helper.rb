module Account::EventsHelper
  def twitter_share(msg, link_text='Tweet this event!')
    msg = CGI::escape(msg)
    # '%|' below denotes a multiline string
    %|
    <div class="social-btn"><a id="twitter-btn" class="social-btn" target="_blank" onclick="return popup(this, 'twitter', 850, 500)" href="http://twitter.com/home?status=#{msg}"><img src="/themes/aflcio/images/Twitter_32x32.png" align="left" hspace="5" valign="absmiddle" border="0" /> <span class="social-text">#{link_text}</span></a>
    </div>
    |.html_safe 
  end
  
  def facebook_share(msg, title, link_text=false)
    link_text ||= 'Share this event on Facebook!'
    msg = CGI::escape(msg)
    title = CGI::escape(title)
    %|
    <div class="social-btn"><a id="facebook-btn" class="socal-btn" target="_blank" onclick="return popup(this, 'facebook', 560, 400)"  href="http://www.facebook.com/sharer.php?u=#{msg}&t=#{title}"><img src="/themes/aflcio/images/FaceBook_32x32.png" hspace="5" border="0" valign="left" align="left"/> <span class="social-text">#{link_text}</span></a>
    </div>     
    |.html_safe
  end
end
