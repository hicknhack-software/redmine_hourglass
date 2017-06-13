Rswag::Api.configure do |c|
  c.swagger_root = File.join Hourglass::PLUGIN_ROOT, 'swagger'
end

def files_for_docs_version
  (
  Dir["#{File.join(Hourglass::PLUGIN_ROOT, 'spec', 'integration')}/*"] +
      Dir["#{File.join(Hourglass::PLUGIN_ROOT, 'controllers', 'hourglass')}/*"] +
      [File.join(Hourglass::PLUGIN_ROOT, 'spec', 'swagger_helper.rb')] +
      [File.join(Hourglass::PLUGIN_ROOT, 'spec', 'support', 'model_definitions.yml')]
  ).reject { |f| File.directory?(f) }
end

module Hourglass
  def swagger_docs_version
    Digest::MD5.hexdigest(files_for_docs_version.map { |f| File.read(f) }.join)
  end
end
