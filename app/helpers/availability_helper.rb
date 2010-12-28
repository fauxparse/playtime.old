module AvailabilityHelper
  def weekend(dates)
    "#{dates.first.strftime(dates.first.month == dates.last.month ? "%e" : "%e %b")} &amp; #{dates.last.strftime("%e %b")}".html_safe
  end
  
  def availability_for(show, jester)
    available = if show.new_record?
      jester.active?
    else
      show.players.any? { |p| p.jester_id == jester.id }
    end
    name = "shows[#{show.date.to_s(:db)}][availability][]"
    id = "shows_#{show.date.to_s(:db)}_availability_#{jester.id}"
    title = show.date.strftime("%a")
    (check_box_tag(name, jester.id, available, :title => title, :id => id) + label_tag(id, title)).html_safe
  end

end
