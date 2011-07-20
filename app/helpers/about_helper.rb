module AboutHelper
  
  # determine whether or not the provided facet actually exists and has a value
  # if it does, output it as a bio <dl> item
  def facet_print(facet, dd_class = false)
    if facet && !facet.value.blank?
      logger.debug "Printing facet: " + facet.slug
      dd_attr = dd_class ? "class='#{dd_class}'" : ''
      out = "<dt>#{facet.name}</dt>\n<dd #{dd_attr}>#{facet_value facet.value}</dd>\n"
      sanitize out, :tags => %w(a strong em u br cite span ol ul li dd dt)
    else
      ''
    end
  end
  
end
