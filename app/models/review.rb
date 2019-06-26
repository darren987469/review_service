class Review < ApplicationRecord
  enum rating_type: {
    star: 0,
    thumb: 1
  }

  scope :active, -> { where(active: true) }
end
