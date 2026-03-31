class RenameActionTextBodiesForLocale < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      UPDATE action_text_rich_texts
      SET name = 'body_en'
      WHERE name = 'body'
      AND record_type IN ('Article', 'Page')
    SQL
  end

  def down
    execute <<-SQL.squish
      UPDATE action_text_rich_texts
      SET name = 'body'
      WHERE name = 'body_en'
      AND record_type IN ('Article', 'Page')
    SQL
  end
end
