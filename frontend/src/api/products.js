import api from './axios'

export default {
  getAll(params) {
    return api.get('/products', { params })
  },

  getById(id) {
    return api.get(`/products/${id}`)
  },

  getBySlug(slug) {
    return api.get(`/products/slug/${slug}`)
  },

  getByCategory(categoryId, params) {
    return api.get(`/products/category/${categoryId}`, { params })
  }
}
