class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.references :rater, polymorphic: true
      t.references :rateable, polymorphic: true
      t.integer :rating_type, default: 0
      t.integer :rating
      t.string :comment
      t.boolean :active, default: true
      t.jsonb :metadata
      t.timestamps
    end
  end
end
