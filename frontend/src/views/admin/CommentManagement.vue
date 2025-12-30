<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold text-gray-900">评论管理</h1>
    </div>
    
    <!-- Table -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              评论内容
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              用户
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              所属文章
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              发布时间
            </th>
            <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
              操作
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="comment in comments" :key="comment.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">
              <p class="text-sm text-gray-900 max-w-md truncate">{{ comment.content }}</p>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <router-link :to="`/user/${comment.user.id}`" class="text-sm text-primary-600 hover:underline">
                {{ comment.user.username }}
              </router-link>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <router-link :to="`/article/${comment.article.id}`" class="text-sm text-gray-600 hover:underline">
                {{ comment.article.title?.substring(0, 20) || '文章' }}...
              </router-link>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(comment.createdAt) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <button 
                @click="deleteComment(comment.id)"
                class="text-red-600 hover:text-red-900"
              >
                删除
              </button>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- Empty state -->
      <div v-if="comments.length === 0" class="text-center py-12">
        <p class="text-gray-500">暂无评论</p>
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
import { commentApi } from '@/api/article'
import { useToastStore } from '@/stores/toast'

const toastStore = useToastStore()

const loading = ref(true)
const comments = ref([])
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
    hour: '2-digit',
    minute: '2-digit'
  })
}

const loadComments = async () => {
  loading.value = true
  
  try {
    const response = await commentApi.getAllComments({ page: pagination.page, size: pagination.size })
    
    if (response.success) {
      comments.value = response.data.content
      pagination.page = response.data.page
      pagination.size = response.data.size
      pagination.totalElements = response.data.totalElements
      pagination.totalPages = response.data.totalPages
    }
  } catch (error) {
    console.error('Failed to load comments:', error)
    toastStore.showError('加载失败')
  } finally {
    loading.value = false
  }
}

const deleteComment = async (id) => {
  if (!confirm('确定要删除这条评论吗？')) return
  
  try {
    const response = await commentApi.delete(id)
    if (response.success) {
      toastStore.showSuccess('删除成功')
      loadComments()
    } else {
      toastStore.showError(response.error || '删除失败')
    }
  } catch (error) {
    toastStore.showError('删除失败')
  }
}

const changePage = (page) => {
  pagination.page = page
  loadComments()
}

onMounted(() => {
  loadComments()
})
</script>
