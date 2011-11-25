class String
  def symbolize
    self.strip.downcase.gsub(/\s+/, "_")
  end
end
