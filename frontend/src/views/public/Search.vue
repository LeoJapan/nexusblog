<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Search Content -->
      <div class="lg:col-span-2">
        <!-- Search Header -->
        <div class="mb-6">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">
            搜索: "{{ keyword }}"
          </h1>
          <p class="text-gray-600">
            共找到 {{ pagination.totalElements }} 篇文章
          </p>
        </div>
        
        <!-- Search Form -->
        <form @submit.prevent="handleSearch" class="mb-8">
          <div class="flex space-x-4">
            <input 
              v-model="searchKeyword"
              type="text"
              placeholder="搜索文章、作者、标签..."
              class="flex-1 px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            >
            <button 
              type="submit"
              class="px-6 py-3 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors"
            >
              搜索
            </button>
          </div>
        </form>
        
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
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <p class="text-gray-500 mb-4">未找到相关文章</p>
            <p class="text-sm text-gray-400">尝试其他关键词或浏览分类</p>
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
          <h3 class="text-lg font-bold text-gray-900 mb-4">分类</h3>
          <div class="flex flex-wrap gap-2">
            <router-link 
              v-for="cat in categories" 
              :key="cat"
              :to="`/category/${cat}`"
              class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-sm hover:bg-primary-100 hover:text-primary-700 transition-colors"
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
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useArticleStore } from '@/stores/article'
import ArticleCard from '@/components/ArticleCard.vue'

const route = useRoute()
const router = useRouter()
const articleStore = useArticleStore()

const loading = ref(true)
const searchKeyword = ref(route.query.keyword || '')

const articles = computed(() => articleStore.articles)
const categories = computed(() => articleStore.categories)
const popularArticles = computed(() => articleStore.popularArticles)
const pagination = computed(() => articleStore.pagination)

const keyword = computed(() => route.query.keyword || '')

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
    keyword: keyword.value
  })
  loading.value = false
}

const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push({ name: 'Search', query: { keyword: searchKeyword.value.trim() } })
  }
}

const changePage = (page) => {
  articleStore.setPage(page)
  loadArticles()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

onMounted(async () => {
  if (route.query.keyword) {
    searchKeyword.value = route.query.keyword
    await loadArticles()
  }
  
  await Promise.all([
    articleStore.fetchPopularArticles(),
    articleStore.fetchCategories()
  ])
})
</script>
