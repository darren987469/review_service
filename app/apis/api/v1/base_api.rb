module API
  module V1
    class BaseAPI < Grape::API
      mount ReviewAPI
    end
  end
end
