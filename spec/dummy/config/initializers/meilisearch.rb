MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch('MEILISEARCH_URL') { 'http://localhost:7700' },
  meilisearch_api_key: ENV['MEILI_MASTER_KEY'],
  logger: Rails.env.test? ? Logger.new(nil) : Rails.logger
}