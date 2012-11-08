def scrub html
  #html.gsub /(<script[^>]*>|<\/script>)/i, ""
  Sanitize.clean(html, :elements => %w[a span p font br img b em h2 h3 h4 h5 ul li blockquote hr],
    :attributes => {
      'a' => %w[href title],
      'span' => %w[style],
      'p' => %w[style title],
      'font' => %w[style size color face],
      'img' => %w[src alt],
      'b' => %w[style],
      'em' => %w[style],
      'h2' => %w[style],
      'h3' => %w[style],
      'h4' => %w[style],
      'h5' => %w[style],
      'ul' => %w[style],
      'li' => %w[style],
      'blockquote' => %w[style],
      'hr' => %w[style]
    },
    :protocols => {
      'a' => {'href' => ['http', 'https', 'mailto', :relative]},
      'img' => {'src' => ['http', 'https', :relative]}
    }
  )
end
