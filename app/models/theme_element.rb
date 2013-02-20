class ThemeElement < ActiveRecord::Base
  belongs_to :theme

  def escaped_markdown
    CGI.escapeHTML(self.attributes["markdown"])
  end

end
