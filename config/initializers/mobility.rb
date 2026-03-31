# Mobility configuration for content translation (English + Bangla)
# Uses JSONB backend for zero-JOIN performance on PostgreSQL
#
# Column naming: translates :title stores in "title" JSONB column (same name).
# Migrations convert existing string columns to JSONB and migrate data.
Mobility.configure do
  plugins do
    backend :jsonb
    active_record
    reader
    writer
    backend_reader
    query
    cache
    presence
    fallbacks({ bn: :en })
    locale_accessors %i[en bn]
  end
end
