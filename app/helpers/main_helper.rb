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
      facet_start = facet.index.byteStart
      facet_end = facet.index.byteEnd
      replace_text = skeet_text.byteslice(facet_start, (facet_end-facet_start))
      case facet.features.first['$type']
      when 'app.bsky.richtext.facet#link'
        replacements << [replace_text, facet.features.first.uri]
      when 'app.bsky.richtext.facet#mention'
        replacements << [replace_text, "https://bsky.app/profile/#{facet.features.first.did}"]
      when 'app.bsky.richtext.facet#tag'
        replacements << [replace_text, "https://bsky.app/hashtag/#{facet.features.first.tag}"]
      end
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
    logger.debug "************ final skeet text: #{skeet_text}"
    return skeet_text
  end

end
