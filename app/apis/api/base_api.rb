module API
  class BaseAPI < Grape::API
    format :json

    rescue_from Grape::Exceptions::ValidationErrors do |error|
      error!(error.message, 400)
    end

    rescue_from ActiveRecord::RecordNotFound do |_error|
      error!('Not Found.', 404)
    end

    if Rails.env.production? || Rails.env.staging?
      rescue_from :all do |_error|
        error!('Internal Server Error.', 500)
      end
    end

    mount API::V1::BaseAPI => '/v1'
  end
end
