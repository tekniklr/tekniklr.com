module GotyHelper

  def goty_nav(gotys, year)
    (gotys.size <= 1) and return
    content_tag :ol, class: "goty_links", role: 'navigation', 'aria-label': "GOTY years" do
      gotys.each do |goty|
        list_item = if logged_in? && (goty.year == Date.today.year)
                      link_to goty.year, edit_goty_path
                    elsif (goty.year == year)
                      goty.year
                    elsif goty.published?
                      link_to goty.year, goty_path(year: goty.year)
                    else
                      next
                    end
        concat(content_tag(:li, list_item))
      end
    end
  end

  # accepts either a goty or a goty_game - just needs an 'id' attribute and an
  # 'explanation' attribute
  def goty_explanation(goty)
    text = simple_format(goty.explanation)
    text.scan(/\|\|(.*)\|\|/).each_with_index do |match, index|
      spoiler = match.first
      logger.debug "************ hiding spoiler #{index+1} for goty #{goty.id}: #{spoiler}"
      spoiler_id = "spoiler_#{goty.id}_#{index}"
      spoiler_content = spoiler.gsub /\|\|/, ''
      spoiler_placeholder = spoiler_content.gsub(/./, '&nbsp; ') # replace all spoiler text with a non-breaking space followed by a regular space, so long spoilers will have line wraps. however, this means they will display as twice as long as the original text
      spoiler_placeholder = spoiler_placeholder[0,(7*(spoiler_content.size/2))] # truncate the too-long placeholder to the correct length, without truncating in the middle of a &nbsp;
      concealed = "<span class='spoiler_concealed' id='#{spoiler_id}'>#{spoiler_content}</span><span class='spoiler_reveal' data-id='#{spoiler_id}'>#{spoiler_placeholder}</span>"
      text.gsub! "||#{spoiler}||", concealed
    end
    text.html_safe
  end

end