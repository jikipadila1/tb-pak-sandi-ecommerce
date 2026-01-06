import { defineStore } from 'pinia'
import authApi from '../api/auth'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user')) || null,
    token: localStorage.getItem('token') || null,
    isAuthenticated: !!localStorage.getItem('token')
  }),

  getters: {
    isAdmin: (state) => state.user?.role === 'admin'
  },

  actions: {
    async login(credentials) {
      try {
        const { data } = await authApi.login(credentials)
        this.token = data.data.token
        this.user = data.data.user
        this.isAuthenticated = true
        localStorage.setItem('token', this.token)
        localStorage.setItem('user', JSON.stringify(this.user))
        return data
      } catch (error) {
        throw error
      }
    },

    async register(userData) {
      try {
        const { data } = await authApi.register(userData)
        this.token = data.data.token
        this.user = data.data.user
        this.isAuthenticated = true
        localStorage.setItem('token', this.token)
        localStorage.setItem('user', JSON.stringify(this.user))
        return data
      } catch (error) {
        throw error
      }
    },

    logout() {
      this.user = null
      this.token = null
      this.isAuthenticated = false
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    },

    async fetchUser() {
      if (this.token) {
        try {
          const { data } = await authApi.me()
          this.user = data.data
          this.isAuthenticated = true
          localStorage.setItem('user', JSON.stringify(this.user))
        } catch (error) {
          this.logout()
        }
      }
    }
  }
})
