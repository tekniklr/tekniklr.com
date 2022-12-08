module ApplicationHelper
  
  # will output the value of a given facet with the optional provided styling;
  # if the facet has multiple lines it will be converted to a list
  def facet_value(value, list = false, cssclass = false, csselclass = false)
    if value
      lines = value.split("\n")
      if lines.size > 1
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
      sanitize out, tags: %w(a strong em u br cite span ol ul li), attributes: %w(href target name title src alt class)
    else
      ''
    end
  end

  # wrapper for time_ago_in_words that won't go into minutia
  def how_long_ago(date)
    if date.to_date == Date.today
      return 'today'
    elsif date.to_date == Date.yesterday
      return 'yesterday'
    else
      return  time_ago_in_words(date)+' ago'
    end
  end
  
  private

  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(class: classes)
  end
    
end
