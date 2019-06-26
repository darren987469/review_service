require 'rails_helper'

RSpec.describe Review, type: :model do
  context 'User rates store' do
    context 'query average rating of store' do
      before do
        attrs = { rater_id: 1, rater_type: 'User', rating_type: 'star' }
        values = [
          { rateable_id: 1, rateable_type: 'Store',  rating: 1 },
          { rateable_id: 1, rateable_type: 'Store',  rating: 5 },
          { rateable_id: 2, rateable_type: 'Store',  rating: 2 }
        ]
        values.each { |value| Review.create(attrs.merge(value)) }
      end
      let(:expected) do
        [
          { store_id: 1, rating_count: 2, rating_average: 3  },
          { store_id: 2, rating_count: 1, rating_average: 2  }
        ]
      end

      it 'returns aggregated result' do
        results = Review.where(rateable_type: 'Store').
          group(:rateable_id).
          select('rateable_id as store_id').
          select('COUNT(*) as rating_count').
          select('AVG(rating) as rating_average').
          map do |record|
            {
              store_id: record.store_id,
              rating_count: record.rating_count,
              rating_average: record.rating_average
            }
          end
        expect(results).to match_array expected
      end
    end
  end

  context 'User rates order item' do
    context 'query thumb up count of product by store' do
      before do
        attrs = {
          rater_id: 1,
          rater_type: 'User',
          rating_type: 'thumb',
          rateable_type: 'OrderItem',
          rating: 1
        }
        values = [
          { rateable_id: 1, metadata: { store_id: 1, product_id: 1 } },
          { rateable_id: 2, metadata: { store_id: 1, product_id: 1 } },
          { rateable_id: 3, metadata: { store_id: 1, product_id: 2 } },
          { rateable_id: 4, metadata: { store_id: 2, product_id: 1 } },
        ]
        values.each { |value| Review.create(attrs.merge(value)) }
      end
      let(:expected) do
        [
          { store_id: 1, product_id: 1, thumb_up_count: 2 },
          { store_id: 1, product_id: 2, thumb_up_count: 1 },
          { store_id: 2, product_id: 1, thumb_up_count: 1 }
        ]
      end

      it 'returns aggregated result' do
        results = Review.where(rateable_type: 'OrderItem', rating: 1).
          group("metadata -> 'store_id', metadata -> 'product_id'").
          select("metadata -> 'store_id' as store_id").
          select("metadata -> 'product_id' as product_id").
          select('COUNT(*) as thumb_up_count').
          map do |record|
            {
              store_id: record.store_id,
              product_id: record.product_id,
              thumb_up_count: record.thumb_up_count
            }
          end
        expect(results).to match_array expected
      end
    end
  end
end
