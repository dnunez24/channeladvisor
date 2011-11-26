class Symbol
  def stringify
    self.to_s.downcase.gsub(/_/, " ")
  end
end
