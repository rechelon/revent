class ThemeElement < ActiveRecord::Base
  belongs_to :theme
  def markdown
    CGI.escapeHTML(self.attributes["markdown"])
  end
end
