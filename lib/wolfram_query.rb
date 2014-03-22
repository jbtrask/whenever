class WolframQuery

  def self.fetch(wql)
    Wolfram.appid = ENV['WOLFRAM_APPID']
    Wolfram.query(wql).fetch
  end

  def self.fetch_hash(wql)
    result = self.fetch(wql)
    Wolfram::HashPresenter.new(result).to_hash
  end

end