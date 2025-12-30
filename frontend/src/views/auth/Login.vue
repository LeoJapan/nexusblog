<template>
  <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center py-12 px-4">
    <div class="max-w-md w-full">
      <!-- Card -->
      <div class="bg-white rounded-2xl shadow-xl p-8">
        <!-- Header -->
        <div class="text-center mb-8">
          <div class="w-12 h-12 bg-gradient-to-br from-primary-500 to-primary-700 rounded-xl flex items-center justify-center mx-auto mb-4">
            <span class="text-white font-bold text-xl">N</span>
          </div>
          <h1 class="text-2xl font-bold text-gray-900">欢迎回来</h1>
          <p class="text-gray-600 mt-2">登录您的账户</p>
        </div>
        
        <!-- Form -->
        <form @submit.prevent="handleLogin" class="space-y-6">
          <!-- Username -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              用户名
            </label>
            <input 
              v-model="form.username"
              type="text"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="请输入用户名"
            >
          </div>
          
          <!-- Password -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              密码
            </label>
            <input 
              v-model="form.password"
              type="password"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="请输入密码"
            >
          </div>
          
          <!-- Error message -->
          <div v-if="error" class="bg-red-50 text-red-600 px-4 py-3 rounded-xl text-sm">
            {{ error }}
          </div>
          
          <!-- Submit -->
          <button 
            type="submit"
            :disabled="loading"
            class="w-full py-3 bg-primary-600 text-white rounded-xl font-medium hover:bg-primary-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading">登录中...</span>
            <span v-else>登录</span>
          </button>
        </form>
        
        <!-- Footer -->
        <div class="mt-6 text-center">
          <p class="text-gray-600">
            还没有账户？
            <router-link to="/register" class="text-primary-600 hover:underline">
              立即注册
            </router-link>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const toastStore = useToastStore()

const loading = ref(false)
const error = ref('')
const form = reactive({
  username: '',
  password: ''
})

const handleLogin = async () => {
  loading.value = true
  error.value = ''
  
  const result = await userStore.login(form.username, form.password)
  
  if (result.success) {
    const redirect = route.query.redirect || '/'
    router.push(redirect)
  } else {
    error.value = result.message
  }
  
  loading.value = false
}
</script>
