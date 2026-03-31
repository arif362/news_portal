class AddTranslationsToCategories < ActiveRecord::Migration[8.1]
  def up
    %w[name description meta_title meta_description].each do |col|
      add_column :categories, :"#{col}_jsonb", :jsonb, default: {}

      execute <<-SQL.squish
        UPDATE categories
        SET #{col}_jsonb = CASE
          WHEN #{col} IS NOT NULL AND #{col} != ''
          THEN jsonb_build_object('en', #{col})
          ELSE '{}'::jsonb
        END
      SQL

      remove_column :categories, col.to_sym
      rename_column :categories, :"#{col}_jsonb", col.to_sym
    end
  end

  def down
    %w[name description meta_title meta_description].each do |col|
      add_column :categories, :"#{col}_str", :string

      execute <<-SQL.squish
        UPDATE categories SET #{col}_str = #{col}->>'en'
      SQL

      remove_column :categories, col.to_sym
      rename_column :categories, :"#{col}_str", col.to_sym
    end
  end
end
