import { defineStore } from 'pinia'

export const useToastStore = defineStore('toast', {
  state: () => ({
    toasts: []
  }),
  
  actions: {
    show(message, type = 'info', duration = 3000) {
      const id = Date.now()
      this.toasts.push({ id, message, type })
      
      setTimeout(() => {
        this.remove(id)
      }, duration)
    },
    
    showSuccess(message) {
      this.show(message, 'success')
    },
    
    showError(message) {
      this.show(message, 'error')
    },
    
    showWarning(message) {
      this.show(message, 'warning')
    },
    
    remove(id) {
      const index = this.toasts.findIndex(t => t.id === id)
      if (index > -1) {
        this.toasts.splice(index, 1)
      }
    }
  }
})
