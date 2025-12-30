<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Articles List -->
      <div class="lg:col-span-2">
        <!-- Header -->
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            {{ category }} - 分类下的文章
          </h1>
          <p class="text-gray-600">
            共找到 {{ pagination.totalElements }} 篇文章
          </p>
        </div>
        
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
          <div v-if="articles.length === 0" class="text-center py-12">
            <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            <p class="text-gray-500">该分类下暂无文章</p>
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
      
      <!-- Sidebar -->
      <aside class="lg:col-span-1">
        <!-- Categories -->
        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
          <h3 class="text-lg font-bold text-gray-900 mb-4">所有分类</h3>
          <div class="flex flex-wrap gap-2">
            <router-link 
              v-for="cat in categories" 
              :key="cat"
              :to="`/category/${cat}`"
              class="px-3 py-1 rounded-full text-sm transition-colors"
              :class="cat === category 
                ? 'bg-primary-600 text-white' 
                : 'bg-gray-100 text-gray-700 hover:bg-primary-100 hover:text-primary-700'"
            >
              {{ cat }}
            </router-link>
          </div>
        </div>
        
        <!-- Popular Articles -->
        <div class="bg-white rounded-xl shadow-sm p-6">
          <h3 class="text-lg font-bold text-gray-900 mb-4">热门文章</h3>
          <div class="space-y-4">
            <router-link 
              v-for="article in popularArticles" 
              :key="article.id"
              :to="`/article/${article.id}`"
              class="block group"
            >
              <h4 class="text-gray-900 group-hover:text-primary-600 transition-colors line-clamp-2 text-sm font-medium">
                {{ article.title }}
              </h4>
              <div class="flex items-center text-xs text-gray-500 mt-1">
                <span>{{ article.views }} 阅读</span>
              </div>
            </router-link>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useArticleStore } from '@/stores/article'
import ArticleCard from '@/components/ArticleCard.vue'

const route = useRoute()
const articleStore = useArticleStore()

const loading = ref(true)

const articles = computed(() => articleStore.articles)
const categories = computed(() => articleStore.categories)
const popularArticles = computed(() => articleStore.popularArticles)
const pagination = computed(() => articleStore.pagination)

const category = computed(() => route.params.category)

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
    category: category.value
  })
  loading.value = false
}

const changePage = (page) => {
  articleStore.setPage(page)
  loadArticles()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

watch(category, () => {
  articleStore.setPage(0)
  loadArticles()
})

onMounted(async () => {
  await Promise.all([
    loadArticles(),
    articleStore.fetchPopularArticles(),
    articleStore.fetchCategories()
  ])
})
</script>
