require "csv"

class Show < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  has_friendly_id :date_slug, :use_slug => true
  
  has_many :players, :inverse_of => :show, :dependent => :destroy, :include => :jester
  has_many :jesters, :through => :players
  has_many :notes, :as => :notable, :order => "created_at ASC"
  
  accepts_nested_attributes_for :players

  validates_presence_of :date
  
  scope :after, lambda { |date| where("date >= ?", date) }
  scope :before, lambda { |date| where("date < ?", date) }
  scope :as_player, where("players.role = ?", :player)
  scope :as_mc, where("players.role = ?", :mc)
  scope :as_player_or_mc, where("players.role IS NOT NULL AND players.role <> ''")
  scope :as_usher, where("players.role = ?", :usher)
  
  delegate :params, :to => :date
  
  def self.import(filename)
    shows = {}
    rows = CSV.read(filename)
    rows[3].each_with_index do |str, i|
      if str =~ /(\d{1,2})\/(\d{1,2})\/(\d{2})/
        shows[i] = Show.find_or_create_by_date(Date.civil($3.to_i + 2000, $1.to_i, $2.to_i))
      end
    end
    
    row = 6
    while row < rows.count
      if jester = Jester.find_by_first_name_and_last_name(*(rows[row].first || "").split(/\s+/, 2))
        shows.each_pair do |i, show|
          available, player, mc = rows[row][i].to_i, rows[row + 1][i].to_i, rows[row + 2][i].to_i
          if available + player + mc > 0
            Player.create :show => show, :jester => jester, :role => :mc if mc == 1
            Player.create :show => show, :jester => jester, :role => :player if player == 1
            Player.create :show => show, :jester => jester, :role => nil if mc.zero? && player.zero?
          end
        end
        row += 3
      else
        row += 1
      end
    end
  end
  
  def date_slug
    date.to_s(:db)
  end
  
  def availability=(ids)
    Rails.logger.info "Availability => #{ids.inspect}".green
    self.jester_ids = Array(ids).map(&:to_i)
  end
  
  def mcs
    players.select(&:mcing?).map(&:jester)
  end
  memoize :mcs
  
  def musos
    players.select(&:musoing?).map(&:jester)
  end
  memoize :musos
  
  def playing
    players.select(&:playing?).map(&:jester)
  end
  memoize :playing
  
  def ushers
    players.select(&:ushering?).map(&:jester)
  end
  memoize :ushers
  
  def all_in?
    players.any? && !players.any? { |p| p.role.blank? }
  end
  
  def calendar_description
    "".tap do |str|
      str << "MC: #{mcs.to_sentence}\n" unless mcs.empty?
      str << "Players: #{playing.to_sentence}\n" unless playing.empty?
      str << "Muso: #{musos.to_sentence}\n" unless musos.empty?
      str << "Ushers: #{ushers.to_sentence}\n" unless ushers.empty?
    end
  end
  
  def self.calendar
    RiCal.Calendar do
      Show.where("date > ?", Date.today - 3.months).includes(:players => :jester).each do |show|
        start_time = Time.zone.local(show.date.year, show.date.month, show.date.day, 22, 0)
        event do
          summary     "Scared Scriptless"
          description show.calendar_description
          dtstart     start_time
          dtend       start_time + 1.5.hours
          location    "The Court Theatre"
        end
      end    
    end
    
  end
  
end
