import axios from 'axios'
import { useUserStore } from '@/stores/user'
import router from '@/router'

const api = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const userStore = useUserStore()
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor
api.interceptors.response.use(
  (response) => {
    return response.data
  },
  (error) => {
    const { response } = error
    
    if (response) {
      switch (response.status) {
        case 401:
          // Token expired or invalid
          const userStore = useUserStore()
          userStore.logout()
          router.push({ name: 'Login' })
          break
        case 403:
          // Forbidden
          router.push({ name: 'Home' })
          break
        case 404:
          // Not found
          break
        case 500:
          // Server error
          break
      }
    }
    
    return Promise.reject(error)
  }
)

export default api
