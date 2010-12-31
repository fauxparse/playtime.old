module JestersHelper
  def extended_date(date)
    if date
      "#{date.to_formatted_s(:long)}<small>(#{time_ago_in_words date} ago)</small>".html_safe
    else
      "Never <small>&nbsp;</small>".html_safe
    end
  end
  
  def play_percentage(jester, window = 90.days)
    availability = jester.availability.select { |a| a.show.date > Date.today - window }
    percentage = if availability.any?
      100.0 * availability.select(&:playing?).length / availability.length
    else
      0.0
    end
    content_tag :div, "%.1f%%" % percentage, :class => :"play-percentage data", :"data-value" => percentage
  end
  
  def last_played(jester)
    last = jester.availability.select(&:playing?).last.try :date
    content_tag :div, last.strftime("%d %b").sub(/^0/, ''), :class => :"last-played data", :"data-value" => last.to_formatted_s(:db) if last
  end
  
  def last_mced(jester)
    last = jester.availability.select(&:mcing?).last.try :date
    content_tag :div, last.strftime("%d %b").sub(/^0/, ''), :class => :"last-mced data", :"data-value" => last.to_formatted_s(:db) if last
  end
  
  def portrait(jester, size = 32)
    filename = "/images/jesters/#{size}/#{jester.image}.jpg"
    url = if File.exist?(File.join(Rails.root, "public", filename))
      filename
    else
      "http://placehold.it/#{size}x#{size}&text=Jester"
    end
    image_tag url, :alt => jester.to_s
  end
  
  def clear_floats
    content_tag :div, "", :class => :clear
  end
  
  def navigation(name, target = nil, options = {})
    target ||= send :"#{options[:controller] || name}_path"
    title = options[:title] || name.to_s.humanize
    active = (controller.controller_name == (options[:controller] || name.to_s))
    link_to title, target, :class => "#{name}#{' active' if active}"
  end
  
  def frequency(n)
    case n
    when 1 then "once"
    when 2 then "twice"
    else pluralize n, "time"
    end
  end
  
  def recent_play(jester)
    f = @jester.shows.as_player.before(Date.today).after(1.month.ago).count
    if f.zero?
      if last_show = @jester.shows.as_player.before(Date.today).order("shows.date ASC").last
        "This Jester last played about #{time_ago_in_words(last_show.date)} ago."
      else
        "This Jester has no recorded play time."
      end
    else
      "This Jester has played #{frequency(f)} in the last month."
    end
  end
  
end
