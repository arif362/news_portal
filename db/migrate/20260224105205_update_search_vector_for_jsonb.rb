class UpdateSearchVectorForJsonb < ActiveRecord::Migration[8.1]
  def up
    execute "DROP TRIGGER IF EXISTS articles_search_vector_update ON articles;"
    execute "DROP FUNCTION IF EXISTS articles_search_vector_trigger();"

    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION articles_search_vector_trigger() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector :=
          setweight(to_tsvector('english', coalesce(NEW.title->>'en', '')), 'A') ||
          setweight(to_tsvector('english', coalesce(NEW.excerpt->>'en', '')), 'B') ||
          setweight(to_tsvector('english', coalesce(NEW.meta_keywords->>'en', '')), 'C');
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

    execute "UPDATE articles SET title = title;"
  end

  def down
    execute "DROP TRIGGER IF EXISTS articles_search_vector_update ON articles;"
    execute "DROP FUNCTION IF EXISTS articles_search_vector_trigger();"

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
end
