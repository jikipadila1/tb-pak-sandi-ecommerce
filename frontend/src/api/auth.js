import api from './axios'

export default {
  login(credentials) {
    return api.post('/auth/login', credentials)
  },

  register(userData) {
    return api.post('/auth/register', userData)
  },

  me() {
    return api.get('/auth/me')
  },

  logout() {
    return api.post('/auth/logout')
  }
}
