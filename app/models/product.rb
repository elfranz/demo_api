class Product < ApplicationRecord
  has_many :order_products, dependent: :destroy
  has_many :orders, through: :order_products

  validates :title, :units_available, :unit_price, presence: true
  validates :hidden, inclusion: { in: [true, false] }
  validates_numericality_of :units_available, :unit_price
  validates :units_available, numericality: { greater_than_or_equal_to: 0 }
end
