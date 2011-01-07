class AddForeignKeyConstraints < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      ALTER TABLE players ADD CONSTRAINT fk_players_show_id
        FOREIGN KEY (show_id) REFERENCES shows (id)
        ON DELETE CASCADE;
        
      ALTER TABLE players ADD CONSTRAINT fk_players_jester_id
        FOREIGN KEY (jester_id) REFERENCES jesters (id)
        ON DELETE RESTRICT;
    SQL
  end

  def self.down
    execute <<-SQL
      ALTER TABLE players DROP CONSTRAINT fk_players_jester_id;
      ALTER TABLE players DROP CONSTRAINT fk_players_show_id;
    SQL
  end
end
