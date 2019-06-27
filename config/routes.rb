Rails.application.routes.draw do
  mount API::BaseAPI => 'api'
  mount GrapeSwaggerRails::Engine => 'swagger'
end
