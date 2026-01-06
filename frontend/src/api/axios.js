import axios from 'axios'

const api = axios.create({
  baseURL: '/api/v1', // Use Vite proxy instead of direct URL
  timeout: 10000, // 10 seconds timeout
  headers: {
    'Content-Type': 'application/json'
  }
})

console.log('Axios instance created with baseURL:', api.defaults.baseURL)

// Add token to requests
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    console.log('Axios: Making request to', config.baseURL + config.url)
    return config
  },
  error => {
    console.error('Axios: Request error', error)
    return Promise.reject(error)
  }
)

// Handle 401 errors
api.interceptors.response.use(
  response => {
    console.log('Axios: Response received', response.status, response.config.url)
    return response
  },
  error => {
    console.error('Axios: Response error', error.message, error.response?.status)
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api
