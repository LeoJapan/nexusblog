<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-3xl font-bold text-gray-900">文章管理</h1>
      <div class="flex items-center space-x-4">
        <select 
          v-model="filterStatus"
          class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
        >
          <option value="">全部状态</option>
          <option value="DRAFT">草稿</option>
          <option value="PUBLISHED">已发布</option>
          <option value="HIDDEN">已隐藏</option>
        </select>
      </div>
    </div>
    
    <!-- Table -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              文章
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              作者
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              分类
            </th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              状态
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
          <tr v-for="article in articles" :key="article.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">
              <div class="max-w-xs">
                <p class="text-sm font-medium text-gray-900 truncate">{{ article.title }}</p>
                <p class="text-xs text-gray-500 mt-1">
                  {{ article.views }} 阅读 · {{ article.likes }} 点赞
                </p>
              </div>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <router-link :to="`/user/${article.authorId}`" class="text-sm text-primary-600 hover:underline">
                {{ article.authorName }}
              </router-link>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs">
                {{ article.category }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <span 
                class="px-2 py-1 rounded text-xs"
                :class="{
                  'bg-yellow-100 text-yellow-800': article.status === 'DRAFT',
                  'bg-green-100 text-green-800': article.status === 'PUBLISHED',
                  'bg-red-100 text-red-800': article.status === 'HIDDEN'
                }"
              >
                {{ statusText(article.status) }}
              </span>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
              {{ formatDate(article.createdAt) }}
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex items-center justify-end space-x-2">
                <!-- Actions for draft articles -->
                <template v-if="article.status === 'DRAFT'">
                  <button 
                    @click="auditArticle(article.id, 'publish')"
                    class="text-green-600 hover:text-green-900"
                    title="发布"
                  >
                    发布
                  </button>
                  <button 
                    @click="auditArticle(article.id, 'reject')"
                    class="text-red-600 hover:text-red-900"
                    title="拒绝"
                  >
                    拒绝
                  </button>
                </template>
                
                <!-- View article -->
                <router-link 
                  :to="`/article/${article.id}`"
                  class="text-gray-600 hover:text-gray-900"
                  title="查看"
                >
                  查看
                </router-link>
                
                <!-- Delete -->
                <button 
                  @click="deleteArticle(article.id)"
                  class="text-red-600 hover:text-red-900"
                  title="删除"
                >
                  删除
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
      
      <!-- Empty state -->
      <div v-if="articles.length === 0" class="text-center py-12">
        <p class="text-gray-500">暂无文章</p>
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
import { ref, reactive, onMounted, watch } from 'vue'
import { adminApi, articleApi } from '@/api/article'
import { useToastStore } from '@/stores/toast'

const toastStore = useToastStore()

const loading = ref(true)
const filterStatus = ref('')
const articles = ref([])
const pagination = reactive({
  page: 0,
  size: 10,
  totalElements: 0,
  totalPages: 0
})

const statusText = (status) => {
  const texts = {
    DRAFT: '草稿',
    PUBLISHED: '已发布',
    HIDDEN: '已隐藏',
    ARCHIVED: '已归档'
  }
  return texts[status] || status
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const loadArticles = async () => {
  loading.value = true
  
  try {
    const response = filterStatus.value === 'DRAFT' 
      ? await adminApi.getPendingArticles({ page: pagination.page, size: pagination.size })
      : await adminApi.getAllArticles({ page: pagination.page, size: pagination.size })
    
    if (response.success) {
      articles.value = response.data.content
      pagination.page = response.data.page
      pagination.size = response.data.size
      pagination.totalElements = response.data.totalElements
      pagination.totalPages = response.data.totalPages
    }
  } catch (error) {
    console.error('Failed to load articles:', error)
    toastStore.showError('加载失败')
  } finally {
    loading.value = false
  }
}

const auditArticle = async (id, action) => {
  try {
    const response = await adminApi.auditArticle(id, action)
    if (response.success) {
      toastStore.showSuccess(response.message || '操作成功')
      loadArticles()
    } else {
      toastStore.showError(response.error || '操作失败')
    }
  } catch (error) {
    toastStore.showError('操作失败')
  }
}

const deleteArticle = async (id) => {
  if (!confirm('确定要删除这篇文章吗？')) return
  
  try {
    const response = await articleApi.delete(id)
    if (response.success) {
      toastStore.showSuccess('删除成功')
      loadArticles()
    } else {
      toastStore.showError(response.error || '删除失败')
    }
  } catch (error) {
    toastStore.showError('删除失败')
  }
}

const changePage = (page) => {
  pagination.page = page
  loadArticles()
}

watch(filterStatus, () => {
  pagination.page = 0
  loadArticles()
})

onMounted(() => {
  loadArticles()
})
</script>
