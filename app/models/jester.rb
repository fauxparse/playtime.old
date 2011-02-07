class Jester < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  acts_as_authentic do |config|
    
  end
  
  has_many :availability, :class_name => "Player", :inverse_of => :jester, :include => :show, :order => "shows.date ASC"
  has_many :shows, :through => :availability
  has_many :minties
  
  has_friendly_id :name, :use_slug => true

  has_attached_file :photo,
    :storage => :s3,
    :s3_credentials => Rails.env.development? ? File.join(Rails.root, "config/s3.yml") : {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    },
    :s3_host_alias => "s3.courtjesters.org.nz",
    :s3_headers => { "Expires" => 1.year.from_now.httpdate },
    :bucket => "s3.courtjesters.org.nz",
    :path => ":attachment/:id/:style.:extension",
    :url => ":s3_alias_url",
    :styles => {
      :tiny => "24x24#",
      :small => "32x32#",
      :medium => "48x48#",
      :large => "240x240#"
    }
  
  scope :admin, where(:admin => true)
  scope :active, where("active = ? AND type = ?", true, Jester)
  scope :except_musos, where("type <> ?", Muso)
  
  def name
    if (n = super).blank?
      [ first_name, last_initial ].join(" ").strip
    else
      n
    end
  end
  
  def last_initial
    last_name.try(:first).try :<<, '.'
  end
  
  alias_attribute :to_s, :name
  
  def role
    super.try :to_sym
  end
  
  def ratio(playing = nil)
    playing ||= availability.all
  end
  
  def last_played
    shows.as_player.where("date < ?", Date.today).includes(:players => :jester).last
  end
  memoize :last_played
  
  def last_played_on
    last_played.try :date
  end
  
  def last_mced
    shows.as_mc.where("date < ?", Date.today).includes(:players => :jester).last
  end
  memoize :last_mced
  
  def last_mced_on
    last_mced.try :date
  end
  
  def percentage(window = 90.days)
    played = shows.as_player.after(window.ago).count
    available = shows.after(window.ago).count
    available.zero? ? 0.0 : 100.0 * played / available
  end
  memoize :percentage
  
  def availability_percentage(window = 90.days)
    100.0 * shows.after(window.ago).count /
    Show.after(window.ago).count
  end
  memoize :availability_percentage
  
  def favourite_players(n = 5)
    Jester.find_by_sql <<-SQL
      SELECT j.id, j.first_name, j.last_name, j.name, j.admin, j.image, j.cached_slug, j.photo_file_name, j.photo_updated_at, COUNT(j.id) AS frequency
      FROM shows s
      JOIN players mc ON mc.show_id = s.id
      JOIN players p ON p.show_id = s.id
      JOIN jesters j ON j.id = p.jester_id
      WHERE mc.role = 'mc'
      AND mc.jester_id = #{id}
      AND p.role = 'player'
      GROUP BY j.id, j.first_name, j.last_name, j.name, j.admin, j.image, j.cached_slug, j.photo_file_name, j.photo_updated_at
      ORDER BY frequency DESC
      LIMIT #{n}
    SQL
  end
  memoize :favourite_players
  
  def most_seen_with(n = 5)
    Jester.find_by_sql <<-SQL
      SELECT j.id, j.first_name, j.last_name, j.name, j.admin, j.image, j.cached_slug, j.photo_file_name, j.photo_updated_at, COUNT(j.id) AS frequency
      FROM shows s
      JOIN players me ON me.show_id = s.id
      JOIN players p ON p.show_id = s.id
      JOIN jesters j ON j.id = p.jester_id
      WHERE me.role = 'player'
      AND me.jester_id = #{id}
      AND p.jester_id <> #{id}
      AND p.role = 'player'
      GROUP BY j.id, j.first_name, j.last_name, j.name, j.admin, j.image, j.cached_slug, j.photo_file_name, j.photo_updated_at
      ORDER BY frequency DESC
      LIMIT #{n}
    SQL
  end
  memoize :most_seen_with

end
