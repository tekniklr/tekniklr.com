# https://stackoverflow.com/questions/1753336/hashkey-to-hash-key-in-ruby

class Hash
  def method_missing(method, *opts)
    m = method.to_s
    if self.has_key?(m.to_sym)
      return self[m.to_sym]
    elsif self.has_key?(m)
      return self[m]
    end
    super
  end
end