import api from './axios'

export default {
  // Get all payment confirmations (for admin)
  getAll(params = {}) {
    return api.get('/admin/payment-confirmations', { params })
  },

  // Get payment confirmation by ID
  getById(id) {
    return api.get(`/admin/payment-confirmations/${id}`)
  },

  // Verify payment confirmation
  verify(id, data = {}) {
    return api.post(`/admin/payment-confirmations/${id}/verify`, data)
  },

  // Reject payment confirmation
  reject(id, data) {
    return api.post(`/admin/payment-confirmations/${id}/reject`, data)
  },

  // Get statistics
  getStats() {
    return api.get('/admin/payment-confirmations/stats')
  },

  // Customer: Submit payment confirmation
  submit(orderId, data) {
    return api.post(`/orders/${orderId}/payment-confirmation`, data)
  },

  // Customer: Get my payment confirmations
  getMy() {
    return api.get('/payment-confirmations/my')
  }
}
