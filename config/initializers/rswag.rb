Rswag::Api.configure do |c|
  c.swagger_root = File.join Hourglass::PLUGIN_ROOT, 'swagger'
end

def files_for_docs_version
  (Dir["#{File.join(Hourglass::PLUGIN_ROOT, 'spec', 'integration')}/*"] +
      Dir["#{File.join(Hourglass::PLUGIN_ROOT, 'controllers', 'hourglass')}/*"] +
      [File.join(Hourglass::PLUGIN_ROOT, 'spec', 'swagger_helper.rb')]).reject { |f| File.directory?(f) }
end

module Hourglass
  SWAGGER_DOCS_VERSION = Digest::MD5.hexdigest(files_for_docs_version.map { |f| File.read(f) }.join)
end
