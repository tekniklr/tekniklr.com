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

end