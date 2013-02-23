module CacheSpecHelpers
  def assert_cached(url) 
    assert page_cache_exists?(url), "#{url} is not cached"
  end

  def page_cache_expired?(url)
    ! page_cache_exists?(url)
  end

  def page_cache_exists?(url)
    File.exists?(page_cache_test_file(url))
  end

  def page_cache_test_file(url)
    File.join(ActionController::Base.page_cache_directory, page_cache_file(url).reverse.chomp('/').reverse)
  end

  def page_cache_file(url)
    ActionController::Base.send :page_cache_file, url.gsub(/$https?:\/\//, ''), nil
  end

  def cache_url(url)
    dir = FileUtils.mkdir_p(File.join(ActionController::Base.page_cache_directory, File.dirname(url)))
    FileUtils.touch(file = File.join(dir, File.basename(url)))
    assert_cached url
  end

  def cache_urls(*urls)
    urls.each {|url| cache_url(url)}
  end
end

module CacheCustomMatchers
  class ExpirePages
    include CacheSpecHelpers
    def initialize(urls)
      @urls = urls 
    end
    def matches?(target)
      require 'parse_tree'
#      require 'parse_tree_extensions'
#      require 'ruby2ruby'
#      @target = target.to_ruby
      target.call
      @expired_pages, @unexpired_pages = @urls.partition {|u| page_cache_expired?(u)}
      @expired_pages == @urls
    end
    def failure_message
      "#{@target.inspect} did not expire:\n#{@unexpired_pages.join("\n")}"
    end
    def negative_failure_message
      "#{@target.inspect} did expire:\n#{@expired_pages.join("\n\t")}"
    end
  end
  def expire_pages(*urls)
    ExpirePages.new(urls.flatten)
  end
  alias :expire_page :expire_pages
end
