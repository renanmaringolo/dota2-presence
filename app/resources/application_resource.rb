class ApplicationResource < Graphiti::Resource
  self.abstract_class = true
  self.adapter = Graphiti::Adapters::ActiveRecord
  self.base_url = "http://localhost:3000"  # Development URL
  self.endpoint_namespace = '/api/v1'
end