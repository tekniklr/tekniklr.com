module ApplicationHelper
  
  # can be called from any view to insert a stylesheet link
  # into the header for that page
  def stylesheet(*args)
    content_for(:header) { stylesheet_link_tag(*args) }
  end
  
  # will output the value of a given facet with the optional provided styling;
  # if the facet has multiple lines it will be converted to a list
  def facet_value(value, list = false, cssclass = false, csselclass = false)
    if value
      lines = value.split("\n")
      if lines.count > 1
        if list
          cssclass ? out = "<ul class='#{cssclass}'>\n" : out = "<ul>\n"
          lines.each do |line|
            csselclass ? out << "<li class='#{csselclass}'>#{line}</li>\n" : out << "<li>#{line}</li>\n"
          end
          out << "</ul>"
        else
          out = lines.join("<br />\n")
        end
      else
        out = "#{lines.first}"
        csselclass and out = "<span class='#{csselclass}'>#{out}</span>"
        cssclass and out = "<span class='#{cssclass}'>#{out}</span>"
      end
      sanitize out, :tags => %w(a strong em u br cite span ol ul li)
    else
      ''
    end
  end
  
end
