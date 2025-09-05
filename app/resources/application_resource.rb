class ApplicationResource < Graphiti::Resource
  self.abstract_class = true
  self.endpoint_namespace = '/api/v1'
end