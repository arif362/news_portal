class AddSearchVectorToArticles < ActiveRecord::Migration[8.1]
  def up
    add_column :articles, :search_vector, :tsvector
    add_index :articles, :search_vector, using: :gin

    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION articles_search_vector_trigger() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector :=
          setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(NEW.excerpt, '')), 'B') ||
          setweight(to_tsvector('english', coalesce(NEW.meta_keywords, '')), 'C');
        RETURN NEW;
      END
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL.squish
      CREATE TRIGGER articles_search_vector_update
        BEFORE INSERT OR UPDATE OF title, excerpt, meta_keywords
        ON articles
        FOR EACH ROW
        EXECUTE FUNCTION articles_search_vector_trigger();
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS articles_search_vector_update ON articles;"
    execute "DROP FUNCTION IF EXISTS articles_search_vector_trigger();"
    remove_column :articles, :search_vector
  end
end
