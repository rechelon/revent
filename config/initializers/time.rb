class Time
  def self.strptime(date, format, now=self.now)
    d = Date._strptime(date, format)
    raise ArgumentError, "invalid strptime format - `#{format}'" unless d
    if seconds = d[:seconds]
      Time.at(seconds)
    else
      year = d[:year]
      year = yield(year) if year && block_given?
      make_time(year, d[:mon], d[:mday], d[:hour], d[:min], d[:sec], d[:sec_fraction], d[:zone], now)
    end
  end
end
