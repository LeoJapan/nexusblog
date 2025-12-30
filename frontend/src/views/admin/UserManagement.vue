<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold text-gray-900">用户管理</h1>
    </div>
    
    <!-- Table -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              用户
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              邮箱
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              角色
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              状态
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              注册时间
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
              操作
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center mr-3 overflow-hidden">
                  <img 
                    v-if="user.avatar" 
                    :src="user.avatar" 
                    :alt="user.username"
                    class="w-full h-full object-cover"
                  >
                  <span v-else class="text-gray-500 font-medium">
                    {{ user.username.charAt(0).toUpperCase() }}
                  </span>
                </div>
                <span class="text-sm font-medium text-gray-900">{{ user.username }}</span>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ user.email }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span 
                class="px-2 py-1 rounded text-xs"
                :class="user.role === 'ADMIN' ? 'bg-purple-100 text-purple-800' : 'bg-gray-100 text-gray-800'"
              >
                {{ user.role === 'ADMIN' ? '管理员' : '普通用户' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span 
                class="px-2 py-1 rounded text-xs"
                :class="user.status === 1 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
              >
                {{ user.status === 1 ? '正常' : '已封禁' }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(user.createdAt) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button 
                v-if="user.status === 1"
                @click="toggleUserStatus(user.id, 0)"
                class="text-red-600 hover:text-red-900 mr-4"
              >
                封禁
              </button>
              <button 
                v-else
                @click="toggleUserStatus(user.id, 1)"
                class="text-green-600 hover:text-green-900 mr-4"
              >
                解封
              </button>
              <router-link 
                :to="`/user/${user.id}`"
                class="text-gray-600 hover:text-gray-900"
              >
                查看
              </router-link>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- Empty state -->
      <div v-if="users.length === 0" class="text-center py-12">
        <p class="text-gray-500">暂无用户</p>
      </div>
    </div>
    
    <!-- Pagination -->
    <div v-if="pagination.totalPages > 1" class="mt-8 flex justify-center">
      <nav class="flex items-center space-x-2">
        <button 
          @click="changePage(pagination.page - 1)"
          :disabled="pagination.page === 0"
          class="p-2 rounded-lg border border-gray-300 hover:bg-gray-100 disabled:opacity-50"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        
        <span class="px-4 py-2">
          {{ pagination.page + 1 }} / {{ pagination.totalPages }}
        </span>
        
        <button 
          @click="changePage(pagination.page + 1)"
          :disabled="pagination.page >= pagination.totalPages - 1"
          class="p-2 rounded-lg border border-gray-300 hover:bg-gray-100 disabled:opacity-50"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
          </svg>
        </button>
      </nav>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { userApi } from '@/api/article'
import { useToastStore } from '@/stores/toast'

const toastStore = useToastStore()

const loading = ref(true)
const users = ref([])
const pagination = reactive({
  page: 0,
  size: 10,
  totalElements: 0,
  totalPages: 0
})

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

const loadUsers = async () => {
  loading.value = true
  
  try {
    const response = await userApi.getAll({ page: pagination.page, size: pagination.size })
    
    if (response.success) {
      users.value = response.data.content
      pagination.page = response.data.page
      pagination.size = response.data.size
      pagination.totalElements = response.data.totalElements
      pagination.totalPages = response.data.totalPages
    }
  } catch (error) {
    console.error('Failed to load users:', error)
    toastStore.showError('加载失败')
  } finally {
    loading.value = false
  }
}

const toggleUserStatus = async (userId, status) => {
  const action = status === 0 ? '封禁' : '解封'
  if (!confirm(`确定要${action}该用户吗？`)) return
  
  try {
    const response = await userApi.updateStatus(userId, status)
    if (response.success) {
      toastStore.showSuccess(`${action}成功`)
      loadUsers()
    } else {
      toastStore.showError(response.error || '操作失败')
    }
  } catch (error) {
    toastStore.showError('操作失败')
  }
}

const changePage = (page) => {
  pagination.page = page
  loadUsers()
}

onMounted(() => {
  loadUsers()
})
</script>
