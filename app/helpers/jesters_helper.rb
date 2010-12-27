module JestersHelper
  def extended_date(date)
    if date
      "#{date.to_formatted_s(:long)}<small>(#{time_ago_in_words date} ago)</small>".html_safe
    else
      "Never <small>&nbsp;</small>".html_safe
    end
  end
  
  def play_percentage(jester, window = 3.months)
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
    Rails.logger.info filename.red
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
  
end
