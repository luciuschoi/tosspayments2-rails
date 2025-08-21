import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    clientKey: String,
    customerKey: String,
    orderId: String,
    orderName: String,
    customerName: String,
    amount: Number,
    successUrl: String,
    failUrl: String
  }

  static targets = ["paymentMethods", "agreement", "paymentButton"]

  connect() {
    this.initializeTossPayments()
  }

  async initializeTossPayments() {
    if (!this.clientKeyValue) {
      console.error('TossPayments 클라이언트 키가 설정되지 않았습니다.')
      alert('결제 서비스를 초기화할 수 없습니다. 관리자에게 문의하세요.')
      return
    }

    try {
      // TossPayments 위젯 초기화
      const tosspayments = TossPayments(this.clientKeyValue)
      this.widgets = tosspayments.widgets({ customerKey: this.customerKeyValue })

      // 결제 수단 렌더링
      await this.widgets.renderPaymentMethods({
        selector: `#${this.paymentMethodsTarget.id}`,
        variantKey: 'DEFAULT'
      })

      // 약관 동의 렌더링
      await this.widgets.renderAgreement({
        selector: `#${this.agreementTarget.id}`
      })
    } catch (error) {
      console.error('TossPayments 초기화 실패:', error)
      alert('결제 서비스 초기화에 실패했습니다: ' + (error.message || error.toString()))
    }
  }

  async requestPayment() {
    try {
      await this.widgets.requestPayment({
        orderId: this.orderIdValue,
        orderName: this.orderNameValue,
        customerName: this.customerNameValue,
        amount: this.amountValue,
        successUrl: this.successUrlValue,
        failUrl: this.failUrlValue
      })
    } catch (error) {
      console.error('결제 요청 실패:', error)
      alert('결제 요청에 실패했습니다: ' + (error.message || error.toString()))
    }
  }
}