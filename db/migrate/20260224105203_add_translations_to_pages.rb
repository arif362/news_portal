class AddTranslationsToPages < ActiveRecord::Migration[8.1]
  def up
    %w[title meta_title meta_description].each do |col|
      add_column :pages, :"#{col}_jsonb", :jsonb, default: {}

      execute <<-SQL.squish
        UPDATE pages
        SET #{col}_jsonb = CASE
          WHEN #{col} IS NOT NULL AND #{col} != ''
          THEN jsonb_build_object('en', #{col})
          ELSE '{}'::jsonb
        END
      SQL

      remove_column :pages, col.to_sym
      rename_column :pages, :"#{col}_jsonb", col.to_sym
    end
  end

  def down
    %w[title meta_title meta_description].each do |col|
      add_column :pages, :"#{col}_str", :string

      execute <<-SQL.squish
        UPDATE pages SET #{col}_str = #{col}->>'en'
      SQL

      remove_column :pages, col.to_sym
      rename_column :pages, :"#{col}_str", col.to_sym
    end
  end
end
