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
  
  def scaffold_navigation(links: [], additional_class: '', label: 'Contextul navigation')
    links.empty? and return
    content_tag :ul, class: "scaffold_navigation #{additional_class}", role: 'navigation', 'aria-label': label do
      links.collect { |link| concat(content_tag(:li, link)) }
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
