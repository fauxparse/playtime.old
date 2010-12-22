module JestersHelper
  def extended_date(date)
    if date
      "#{date.to_formatted_s(:long)}<small>(#{time_ago_in_words date} ago)</small>".html_safe
    else
      "Never <small>&nbsp;</small>".html_safe
    end
  end
end
