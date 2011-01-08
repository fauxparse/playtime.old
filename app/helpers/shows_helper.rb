# encoding: UTF-8

module ShowsHelper
  def previous_show_link(show)
    show = Show.before(show.date).order(:date).last
    content_tag :li, link_to("« #{show.date.to_s(:long)}", show_path(*show.params)) if show.present?
  end

  def next_show_link(show)
    show = Show.after(show.date + 1).order(:date).first
    content_tag :li, link_to("#{show.date.to_s(:long)} »", show_path(*show.params)) if show.present?
  end

end
