# frozen_string_literal: true

# 결제 정보를 저장하는 Payment 모델
class Payment < ApplicationRecord
  validates :order_id, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending confirmed cancelled failed] }

  scope :confirmed, -> { where(status: 'confirmed') }
  scope :pending, -> { where(status: 'pending') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :failed, -> { where(status: 'failed') }

  def confirmed?
    status == 'confirmed'
  end

  def pending?
    status == 'pending'
  end

  def cancelled?
    status == 'cancelled'
  end

  def failed?
    status == 'failed'
  end

  def formatted_amount
    "#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end
end
