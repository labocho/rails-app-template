# rubocop:disable Naming/FileName
require "rack/revision_route"
Rails.application.middleware.use Rack::RevisionRoute, Rails.root, "/revision"
# rubocop:enable Naming/FileName
