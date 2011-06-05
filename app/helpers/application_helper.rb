module ApplicationHelper
  
  # can be called from any view to insert a stylesheet link
  # into the header for that page
  def stylesheet(*args)
    content_for(:header) { stylesheet_link_tag(*args) }
  end
  
end
