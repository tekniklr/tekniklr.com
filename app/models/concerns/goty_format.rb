module GotyFormat
  extend ActiveSupport::Concern
  include ActionView::Helpers::TextHelper

  def formatted_explanation # needed so best_in_place uses full formatting after update
    explanation.blank? and return 'click to add explanation'
    text = simple_format(explanation)
    text.scan(/\|\|(.*)\|\|/).each_with_index do |match, index|
      spoiler = match.first
      logger.debug "************ hiding spoiler #{index+1} for goty #{id}: #{spoiler}"
      spoiler_id = "spoiler_#{id}_#{index}"
      spoiler_content = spoiler.gsub /\|\|/, ''
      spoiler_placeholder = spoiler_content.gsub(/./, '&nbsp; ') # replace all spoiler text with a non-breaking space followed by a regular space, so long spoilers will have line wraps. however, this means they will display as twice as long as the original text
      spoiler_placeholder = spoiler_placeholder[0,(7*(spoiler_content.size/2))] # truncate the too-long placeholder to the correct length, without truncating in the middle of a &nbsp;
      concealed = "<span class='spoiler_concealed' id='#{spoiler_id}'>#{spoiler_content}</span><span class='spoiler_reveal' data-id='#{spoiler_id}'>#{spoiler_placeholder}</span>"
      text.gsub! "||#{spoiler}||", concealed
    end
    text.html_safe
  end

end