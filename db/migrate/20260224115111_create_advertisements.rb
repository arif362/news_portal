class CreateAdvertisements < ActiveRecord::Migration[8.1]
  def change
    create_table :advertisements, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      # Content (JSONB for bilingual support)
      t.jsonb :title, default: {}, null: false
      t.jsonb :description, default: {}
      t.string :slug, null: false

      # Ad content — either image or HTML embed
      t.integer :ad_type, default: 0, null: false
      t.text :embed_code
      t.string :target_url
      t.boolean :open_in_new_tab, default: true

      # Placement & ordering
      t.integer :placement, default: 0, null: false
      t.integer :position, default: 0

      # Status & scheduling
      t.integer :status, default: 0, null: false
      t.datetime :starts_at
      t.datetime :ends_at

      # Analytics
      t.bigint :impressions_count, default: 0, null: false
      t.bigint :clicks_count, default: 0, null: false

      # Metadata
      t.boolean :responsive, default: true
      t.string :alt_text

      t.timestamps
    end

    add_index :advertisements, :slug, unique: true
    add_index :advertisements, :status
    add_index :advertisements, :placement
    add_index :advertisements, [ :status, :placement ]
    add_index :advertisements, :starts_at
    add_index :advertisements, :ends_at
  end
end
