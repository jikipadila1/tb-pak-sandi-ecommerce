import api from './axios'

export default {
  getCart() {
    return api.get('/cart')
  },

  addToCart(data) {
    return api.post('/cart', data)
  },

  updateCart(id, data) {
    return api.put(`/cart/${id}`, data)
  },

  removeFromCart(id) {
    return api.delete(`/cart/${id}`)
  },

  clearCart() {
    return api.delete('/cart')
  }
}
