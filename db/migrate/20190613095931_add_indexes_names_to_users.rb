class AddIndexesNamesToUsers < ActiveRecord::Migration
  def up
    execute(<<SQL)
CREATE INDEX users_on_lower_firstname ON users(LOWER(firstname));
CREATE INDEX users_on_lower_lastname ON users(LOWER(lastname));
SQL
  end

  def down
    execute(<<SQL)
DROP INDEX users_on_lower_firstname;
DROP INDEX users_on_lower_lastname;
SQL
  end
end
