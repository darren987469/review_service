module Entity
  module V1
    class Review < Base
      expose :id
      expose :rater_type
      expose :rater_id
      expose :rateable_type
      expose :rateable_id
      expose :rating_type
      expose :rating
      expose :comment
      expose :metadata
    end
  end
end
