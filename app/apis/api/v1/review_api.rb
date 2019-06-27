module API
  module V1
    class ReviewAPI < Grape::API
      resource :reviews do
        desc 'Get Review by id' do
          success Entity::V1::Review
        end
        get ':id' do
          review = Review.find(params[:id])
          present review, with: Entity::V1::Review
        end

        desc 'Create review' do
          success Entity::V1::Review
        end
        params do
          requires :rater_type, type: String
          requires :rater_id, type: Integer
          requires :rateable_type, type: String
          requires :rateable_id, type: Integer
          requires :rating_type, type: String, values: %w[star thumb]
          requires :rating, type: Integer, values: 1..5
          optional :comment, type: String
          optional :metadata, type: JSON
        end
        post do
          review = Review.create(declared(params))
          present review, with: Entity::V1::Review
        end
      end
    end
  end
end
