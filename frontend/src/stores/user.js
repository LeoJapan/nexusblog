import { defineStore } from 'pinia'
import { authApi } from '@/api/article'
import { useToastStore } from './toast'

export const useUserStore = defineStore('user', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user') || 'null'),
    token: localStorage.getItem('token') || null
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    isAdmin: (state) => state.user?.role === 'ADMIN',
    username: (state) => state.user?.username || '',
    userId: (state) => state.user?.id || null
  },
  
  actions: {
    async login(username, password) {
      try {
        const response = await authApi.login({ username, password })
        if (response.success) {
          this.setAuth(response.data)
          const toastStore = useToastStore()
          toastStore.showSuccess('登录成功')
          return { success: true }
        } else {
          return { success: false, message: response.error || '登录失败' }
        }
      } catch (error) {
        return { success: false, message: error.response?.data?.error || '登录失败' }
      }
    },
    
    async register(username, email, password) {
      try {
        const response = await authApi.register({ username, email, password })
        if (response.success) {
          this.setAuth(response.data)
          const toastStore = useToastStore()
          toastStore.showSuccess('注册成功')
          return { success: true }
        } else {
          return { success: false, message: response.error || '注册失败' }
        }
      } catch (error) {
        return { success: false, message: error.response?.data?.error || '注册失败' }
      }
    },
    
    setAuth(data) {
      this.token = data.token
      this.user = data.user
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(data.user))
    },
    
    logout() {
      this.user = null
      this.token = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    },
    
    async fetchCurrentUser() {
      if (!this.token) return
      
      try {
        const response = await authApi.getCurrentUser()
        if (response.success) {
          this.user = response.data
          localStorage.setItem('user', JSON.stringify(response.data))
        }
      } catch (error) {
        this.logout()
      }
    },
    
    updateUser(userData) {
      this.user = { ...this.user, ...userData }
      localStorage.setItem('user', JSON.stringify(this.user))
    }
  }
})
