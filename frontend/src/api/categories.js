import api from './axios'

export default {
  getAll() {
    return api.get('/categories')
  },

  getById(id) {
    return api.get(`/categories/${id}`)
  }
}
