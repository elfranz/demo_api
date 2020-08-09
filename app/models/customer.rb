class Customer < ApplicationRecord
  has_many :orders

  validates :email, :name, :document_number, :phone_number, :address,
            presence: true
  validates :document_number, uniqueness: true
  validates_numericality_of :document_number, :phone_number
end
