# rubocop:disable Style/ClassAndModuleChildren
require "rails/generators/erb/scaffold/scaffold_generator"

class Haml::ScaffoldGenerator < Erb::Generators::ScaffoldGenerator
  source_root File.expand_path("templates", __dir__)

  protected
  def handler
    :haml
  end
end
# rubocop:enable Style/ClassAndModuleChildren
