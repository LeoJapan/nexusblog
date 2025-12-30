<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <h1 class="text-3xl font-bold text-gray-900 mb-8">我的文章</h1>
    
    <!-- Loading -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="bg-white rounded-xl p-6 animate-pulse">
        <div class="h-4 bg-gray-200 rounded w-20 mb-4"></div>
        <div class="h-6 bg-gray-200 rounded w-3/4 mb-3"></div>
        <div class="h-4 bg-gray-200 rounded w-full mb-2"></div>
      </div>
    </div>
    
    <!-- Articles -->
    <div v-else class="space-y-4">
      <ArticleCard 
        v-for="article in articles" 
        :key="article.id" 
        :article="article"
      />
      
      <!-- Empty state -->
      <div v-if="articles.length === 0" class="text-center py-16 bg-white rounded-xl">
        <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        <h3 class="text-lg font-medium text-gray-900 mb-2">还没有文章</h3>
        <p class="text-gray-600 mb-6">开始分享你的第一篇文章吧</p>
        <router-link 
          to="/editor"
          class="inline-block px-6 py-3 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors"
        >
          写文章
        </router-link>
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
        
        <button 
          v-for="page in visiblePages" 
          :key="page"
          @click="changePage(page)"
          class="px-4 py-2 rounded-lg"
          :class="page === pagination.page 
            ? 'bg-primary-600 text-white' 
            : 'hover:bg-gray-100 text-gray-700'"
        >
          {{ page + 1 }}
        </button>
        
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
import { ref, computed, onMounted } from 'vue'
import { useArticleStore } from '@/stores/article'
import { useUserStore } from '@/stores/user'
import ArticleCard from '@/components/ArticleCard.vue'

const articleStore = useArticleStore()
const userStore = useUserStore()

const loading = ref(true)

const articles = computed(() => articleStore.articles)
const pagination = computed(() => articleStore.pagination)

const visiblePages = computed(() => {
  const current = pagination.value.page
  const total = pagination.value.totalPages
  const pages = []
  
  for (let i = Math.max(0, current - 2); i <= Math.min(total - 1, current + 2); i++) {
    pages.push(i)
  }
  
  return pages
})

const loadArticles = async () => {
  loading.value = true
  await articleStore.fetchArticles({
    authorId: userStore.userId
  })
  loading.value = false
}

const changePage = (page) => {
  articleStore.setPage(page)
  loadArticles()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

onMounted(() => {
  loadArticles()
})
</script>
