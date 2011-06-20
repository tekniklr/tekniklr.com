module AboutHelper
  
  def facet_value(value)
    if value
      lines = value.split("\n")
      if lines.count > 1
        out = lines.join("<br />\n")
        sanitize out, :tags => %w(a strong em u br)
      else
        sanitize lines.first, :tags => %w(a strong em u)
      end
    else
      ''
    end
  end
  
end
