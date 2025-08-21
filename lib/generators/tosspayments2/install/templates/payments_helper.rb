# frozen_string_literal: true

module PaymentsHelper
  def payment_status_class(status)
    case status
    when 'confirmed'
      'bg-success'
    when 'pending'
      'bg-warning'
    when 'cancelled'
      'bg-secondary'
    when 'failed'
      'bg-danger'
    else
      'bg-light'
    end
  end

  def payment_status_text(status)
    case status
    when 'confirmed'
      '결제완료'
    when 'pending'
      '결제대기'
    when 'cancelled'
      '결제취소'
    when 'failed'
      '결제실패'
    else
      status
    end
  end

  def format_currency(amount)
    "#{amount.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end
end
