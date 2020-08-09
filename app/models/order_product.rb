class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true
  validates_numericality_of :quantity
  validate :product_available
  validate :quantity_available
  validates_associated :product

  before_create :subract_units_to_product
  before_update :add_previous_units_to_product

  def product_available
    return if product.blank?

    errors.add(:product, ' - Product is hidden.') if product.hidden
  end

  def quantity_available
    return if product.blank? || quantity.blank?

    errors.add(:product, '- Units not available.') if
      quantity > product.units_available
  end

  private

  def subract_units_to_product
    product.update(units_available: product.units_available - quantity)
  end

  def add_previous_units_to_product
    product.update(units_available: product.units_available + quantity_was)
    product.update(units_available: product.units_available - quantity)
  end
end
