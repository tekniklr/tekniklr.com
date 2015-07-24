module ApplicationHelper
  
  # ie/css hacks: http://www.paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/
  def ie_tag(name=:body, attrs={}, &block)
    attrs.symbolize_keys!
    haml_concat("<!--[if lt IE 7]> #{ tag(name, add_class('ie6', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 7]>    #{ tag(name, add_class('ie7', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if IE 8]>    #{ tag(name, add_class('ie8', attrs), true) } <![endif]-->".html_safe)
    haml_concat("<!--[if gt IE 8]><!-->".html_safe)
    haml_tag name, attrs do
      haml_concat("<!--<![endif]-->".html_safe)
      block.call
    end
  end
  def ie_html(attrs={}, &block)
    ie_tag(:html, attrs, &block)
  end
  def ie_body(attrs={}, &block)
    ie_tag(:body, attrs, &block)
  end
  
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
  
  private

  def add_class(name, attrs)
    classes = attrs[:class] || ''
    classes.strip!
    classes = ' ' + classes if !classes.blank?
    classes = name + classes
    attrs.merge(:class => classes)
  end
    
end
