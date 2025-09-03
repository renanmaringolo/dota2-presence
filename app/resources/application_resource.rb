class ApplicationResource < Graphiti::Resource
  self.abstract_class = true
  self.adapter = Graphiti::Adapters::ActiveRecord
  self.base_url = ENV.fetch('RAILS_API_BASE_URL', 'http://localhost:3000')
  self.endpoint_namespace = '/api/v1'
end