if Rails.env.development?
  ActiveRecordQueryTrace.enabled = true
  ActiveRecordQueryTrace.ignore_cached_queries = true # Default is false.
  ActiveRecordQueryTrace.lines = 0 # Default is 5. Setting to 0 includes entire trace.
  ActiveRecordQueryTrace.colorize = :yellow
  ActiveRecordQueryTrace.query_type = :read
  ActiveRecordQueryTrace.level = :custom
  ActiveRecordQueryTrace.backtrace_cleaner = ->(trace) {
    trace.reject { |line| line =~ /\b(active_record_query_trace|active_support|active_record|modware|schema_monkey|sentry-raven|actionpack|quiet_assets|actionview|rack|lograge|railties|sorcery|puma|request_store|wicked_pdf|gems\/pry)\b/ }
  }
end
