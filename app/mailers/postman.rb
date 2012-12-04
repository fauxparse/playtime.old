class Postman < ActionMailer::Base
  default :from => '"The Court Jesters" <jesters.playtime@gmail.com>'
  
  def cast_list(show, editor)
    @interested_parties = (Jester.admin.all + show.mcs - [editor]).uniq
    @show = show
    @editor = editor
    mail  :to => @interested_parties.collect(&:email),
          :cc => "fauxparse@gmail.com",
          :subject => "Cast for #{show.date.strftime("%e/%m/%y")}"
  end
end
