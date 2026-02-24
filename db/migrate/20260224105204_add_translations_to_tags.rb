class AddTranslationsToTags < ActiveRecord::Migration[8.1]
  def up
    %w[name].each do |col|
      add_column :tags, :"#{col}_jsonb", :jsonb, default: {}

      execute <<-SQL.squish
        UPDATE tags
        SET #{col}_jsonb = CASE
          WHEN #{col} IS NOT NULL AND #{col} != ''
          THEN jsonb_build_object('en', #{col})
          ELSE '{}'::jsonb
        END
      SQL

      remove_column :tags, col.to_sym
      rename_column :tags, :"#{col}_jsonb", col.to_sym
    end
  end

  def down
    %w[name].each do |col|
      add_column :tags, :"#{col}_str", :string

      execute <<-SQL.squish
        UPDATE tags SET #{col}_str = #{col}->>'en'
      SQL

      remove_column :tags, col.to_sym
      rename_column :tags, :"#{col}_str", col.to_sym
    end
  end
end
