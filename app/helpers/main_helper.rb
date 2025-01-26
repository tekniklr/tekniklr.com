module MainHelper
  
  # will generate the closest cromulent fade size for the current step
  # there are 15 total fade styles with gradually increasing transparency
  def fade_level(num_steps, step)
    num_steps = (num_steps > 15) ? 15 : num_steps
    step_size = ((150.to_f/num_steps)/10).round * 10
    step * step_size
  end
  
  # skeets handle links/tags in an overly complicated way
  def skeet_facets(skeet_text, facets)
    replacements = []
    replaced_text = []
    replacing_text = skeet_text
    facets.each do |facet|
      facet_type = facet.features.first['$type']
      if ['app.bsky.richtext.facet#link', 'app.bsky.richtext.facet#mention'].include?(facet_type)
        facet_start = facet.index.byteStart
        facet_end = facet.index.byteEnd
        initial_substring = skeet_text[(facet_start)..(facet_end)]
        full_match = skeet_text.match(/\s([-_.A-z]*#{initial_substring}.*)/)
        facet_start = skeet_text.index(full_match.to_s)+1
        replace_text = skeet_text[(facet_start)..(facet_end)].strip
        case facet_type
        when 'app.bsky.richtext.facet#link'
          replacements << [replace_text, facet.features.first.uri]
        when 'app.bsky.richtext.facet#mention'
          replacements << [replace_text, "https://bsky.app/profile/#{facet.features.first.did}"]
        end
      elsif facet_type == 'app.bsky.richtext.facet#tag'
        tag = facet.features.first.tag
        replacements << ["##{tag}", "https://bsky.app/hashtag/#{tag}"]
      end
      replacements.each do |replace|
        logger.debug "************ processing replacement: #{replace}"
        replacing_text.sub! replace.first, "<a href=\"#{replace.last}\" target=\"_blank\">#{replace.first}</a>"
        replace_index = replacing_text.index(replace.first)+(replace.first.size+4)
        replaced_text << replacing_text[0..replace_index]
        replacing_text = replacing_text[(replace_index+1)..]
      end
      replaced_text << replacing_text
      skeet_text = replaced_text.join(' ')
    end
  end

end
