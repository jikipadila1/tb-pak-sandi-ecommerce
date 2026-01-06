import api from './axios'

export default {
  getAll(params) {
    return api.get('/orders', { params })
  },

  getOrder(id) {
    return api.get(`/orders/${id}`)
  },

  getById(id) {
    return api.get(`/orders/${id}`)
  },

  create(data) {
    return api.post('/orders', data)
  },

  updateStatus(id, status) {
    return api.put(`/orders/${id}/status`, { status })
  },

  cancel(id) {
    return api.put(`/orders/${id}/cancel`)
  },

  // Payment methods
  createPayment(orderId, formData) {
    return api.post(`/orders/${orderId}/payment`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
  },

  getPayments(orderId) {
    return api.get(`/orders/${orderId}/payments`)
  }
}
