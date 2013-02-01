class VarnishSweeper < ActionController::Caching::Sweeper
  private

  def hydra_run_requests hydra, requests
    requests.each do |p|
      hydra.queue p
    end
    hydra.run
  end

  def requests request_method, uris
    requests = []
    uris.each do |uri|
      #make sure url starts with a slash
      uri = '/'+uri unless uri.starts_with?('/')
      VARNISH_SERVERS.each do |v|
        url = v+uri
        Rails.logger.info "PURGING: #{url} for Host: #{Site.current.host.hostname}"
        requests.push Typhoeus::Request.new(url, :method => request_method, :headers => {:Host => Site.current.host.hostname})
      end
    end
    requests
  end

  def purges uris
    requests('PURGE', uris)
  end

  def bans uris
    requests('BAN', uris)
  end

end
