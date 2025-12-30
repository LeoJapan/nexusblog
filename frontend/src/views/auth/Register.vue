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
          <h1 class="text-2xl font-bold text-gray-900">创建账户</h1>
          <p class="text-gray-600 mt-2">加入我们的社区</p>
        </div>
        
        <!-- Form -->
        <form @submit.prevent="handleRegister" class="space-y-6">
          <!-- Username -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              用户名
            </label>
            <input 
              v-model="form.username"
              type="text"
              required
              minlength="3"
              maxlength="50"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="3-50个字符"
            >
          </div>
          
          <!-- Email -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              邮箱
            </label>
            <input 
              v-model="form.email"
              type="email"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="请输入邮箱"
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
              minlength="6"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="至少6个字符"
            >
          </div>
          
          <!-- Confirm Password -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              确认密码
            </label>
            <input 
              v-model="form.confirmPassword"
              type="password"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="请再次输入密码"
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
            <span v-if="loading">注册中...</span>
            <span v-else>注册</span>
          </button>
        </form>
        
        <!-- Footer -->
        <div class="mt-6 text-center">
          <p class="text-gray-600">
            已有账户？
            <router-link to="/login" class="text-primary-600 hover:underline">
            立即登录
            </router-link>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useToastStore } from '@/stores/toast'

const router = useRouter()
const userStore = useUserStore()
const toastStore = useToastStore()

const loading = ref(false)
const error = ref('')
const form = reactive({
  username: '',
  email: '',
  password: '',
  confirmPassword: ''
})

const handleRegister = async () => {
  // Validation
  if (form.password !== form.confirmPassword) {
    error.value = '两次输入的密码不一致'
    return
  }
  
  if (form.password.length < 6) {
    error.value = '密码长度至少6个字符'
    return
  }
  
  loading.value = true
  error.value = ''
  
  const result = await userStore.register(form.username, form.email, form.password)
  
  if (result.success) {
    router.push('/')
  } else {
    error.value = result.message
  }
  
  loading.value = false
}
</script>
