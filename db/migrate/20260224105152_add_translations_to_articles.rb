class AddTranslationsToArticles < ActiveRecord::Migration[8.1]
  def up
    # Drop search vector trigger first — it depends on title, excerpt, meta_keywords columns.
    # The update_search_vector_for_jsonb migration will recreate it for JSONB.
    execute "DROP TRIGGER IF EXISTS articles_search_vector_update ON articles;"
    execute "DROP FUNCTION IF EXISTS articles_search_vector_trigger();"

    # Convert translatable columns from string/text to JSONB
    # Migrate existing data into { "en" => value } format
    %w[title excerpt meta_title meta_description meta_keywords].each do |col|
      # Add temporary JSONB column
      add_column :articles, :"#{col}_jsonb", :jsonb, default: {}

      # Migrate existing data
      execute <<-SQL.squish
        UPDATE articles
        SET #{col}_jsonb = CASE
          WHEN #{col} IS NOT NULL AND #{col} != ''
          THEN jsonb_build_object('en', #{col})
          ELSE '{}'::jsonb
        END
      SQL

      # Drop old column and rename new one
      remove_column :articles, col.to_sym
      rename_column :articles, :"#{col}_jsonb", col.to_sym
    end

    # Add GIN indexes for JSONB query performance
    add_index :articles, :title, using: :gin, name: "index_articles_on_title_gin"
  end

  def down
    remove_index :articles, name: "index_articles_on_title_gin", if_exists: true

    %w[title excerpt meta_title meta_description meta_keywords].each do |col|
      add_column :articles, :"#{col}_str", :string

      execute <<-SQL.squish
        UPDATE articles
        SET #{col}_str = #{col}->>'en'
      SQL

      remove_column :articles, col.to_sym
      rename_column :articles, :"#{col}_str", col.to_sym
    end

    # Restore the original search vector trigger for string columns
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
