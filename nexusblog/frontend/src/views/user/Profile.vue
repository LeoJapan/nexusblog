<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">个人资料</h1>
    
    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Profile Form -->
      <div class="lg:col-span-2">
        <div class="bg-white rounded-xl shadow-sm p-8">
          <h2 class="text-xl font-bold text-gray-900 mb-6">基本信息</h2>
          
          <form @submit.prevent="handleSubmit" class="space-y-6">
            <!-- Avatar -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                头像
              </label>
              <div class="flex items-center space-x-4">
                <div class="w-20 h-20 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                  <img 
                    v-if="form.avatar" 
                    :src="form.avatar" 
                    :alt="form.username"
                    class="w-full h-full object-cover"
                  >
                  <span v-else class="text-gray-500 text-2xl font-bold">
                    {{ form.username?.charAt(0).toUpperCase() }}
                  </span>
                </div>
                <input 
                  v-model="form.avatar"
                  type="url"
                  class="flex-1 px-4 py-2 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                  placeholder="头像图片链接"
                >
              </div>
            </div>
            
            <!-- Username -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                用户名
              </label>
              <input 
                v-model="form.username"
                type="text"
                minlength="3"
                maxlength="50"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
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
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
            </div>
            
            <!-- Submit -->
            <div class="flex justify-end">
              <button 
                type="submit"
                :disabled="loading"
                class="px-6 py-3 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors disabled:opacity-50"
              >
                {{ loading ? '保存中...' : '保存修改' }}
              </button>
            </div>
          </form>
        </div>
      </div>
      
      <!-- Sidebar -->
      <div class="lg:col-span-1">
        <!-- Stats -->
        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 class="font-bold text-gray-900 mb-4">统计数据</h3>
          <div class="space-y-4">
            <div class="flex justify-between">
              <span class="text-gray-600">文章数</span>
              <span class="font-medium">{{ user.articleCount || 0 }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">评论数</span>
              <span class="font-medium">{{ user.commentCount || 0 }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">角色</span>
              <span class="font-medium">{{ user.role === 'ADMIN' ? '管理员' : '普通用户' }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-gray-600">加入时间</span>
              <span class="font-medium">{{ formatDate(user.createdAt) }}</span>
            </div>
          </div>
        </div>
        
        <!-- Logout -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <button 
            @click="handleLogout"
            class="w-full px-4 py-3 border border-red-300 text-red-600 rounded-xl hover:bg-red-50 transition-colors"
          >
            退出登录
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useToastStore } from '@/stores/toast'
import { userApi } from '@/api/article'

const router = useRouter()
const userStore = useUserStore()
const toastStore = useToastStore()

const loading = ref(false)
const user = computed(() => userStore.user)

const form = reactive({
  username: '',
  email: '',
  avatar: ''
})

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const handleSubmit = async () => {
  if (!form.username.trim()) {
    toastStore.showError('用户名不能为空')
    return
  }
  
  loading.value = true
  
  try {
    const response = await userApi.updateProfile(form)
    
    if (response.success) {
      userStore.updateUser(response.data)
      toastStore.showSuccess('资料更新成功')
    } else {
      toastStore.showError(response.error || '更新失败')
    }
  } catch (error) {
    toastStore.showError('更新失败')
  } finally {
    loading.value = false
  }
}

const handleLogout = () => {
  userStore.logout()
  router.push('/')
}

onMounted(() => {
  if (user.value) {
    form.username = user.value.username
    form.email = user.value.email
    form.avatar = user.value.avatar || ''
  }
})
</script>
