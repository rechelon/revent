require 'typhoeus'
class ShortLine
  def self.queue(receiver_name, path, post_vars)

    url = "http://#{SHORTLINE_IP}:#{SHORTLINE_PORT}/push"
    
    response = Typhoeus::Request.post(
      url,
      :params => post_vars,
      :headers => {
        :'X-Receiver-Name' => receiver_name,
        :'X-Path' => path,
      },
      :timeout => SHORTLINE_TIMEOUT * 1000)

    if !response.success?
      raise 'Could not connect to ShortLine server'
    end
    
    if response.code != 200
      raise "#{response.code} Error: ShortLine server reached but job not queued"
    end

    response.success?
  end
end
