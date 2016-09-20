class String
  def hashify
    Hash[self.force_encoding("UTF-8").split("&").map! { |i| i.split("=") }]
  end
end
