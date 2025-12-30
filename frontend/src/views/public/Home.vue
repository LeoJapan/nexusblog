<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Hero Section -->
    <section class="mb-12 text-center">
      <h1 class="text-4xl font-bold text-gray-900 mb-4">
        探索精彩内容
      </h1>
      <p class="text-xl text-gray-600 max-w-2xl mx-auto">
        在这里分享知识、表达观点，与志同道合的人交流
      </p>
      
      <!-- Search bar -->
      <div class="mt-8 max-w-xl mx-auto">
        <router-link 
          to="/search"
          class="flex items-center px-4 py-3 bg-white border border-gray-300 rounded-xl shadow-sm hover:shadow-md transition-shadow"
        >
          <svg class="w-5 h-5 text-gray-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <span class="text-gray-500">搜索文章、作者、标签...</span>
        </router-link>
      </div>
    </section>
    
    <!-- Featured Articles -->
    <section v-if="featuredArticles.length > 0" class="mb-12">
      <h2 class="text-2xl font-bold text-gray-900 mb-6">精选文章</h2>
      <div class="grid md:grid-cols-2 gap-6">
        <router-link 
          v-for="article in featuredArticles" 
          :key="article.id"
          :to="`/article/${article.id}`"
          class="group"
        >
          <article class="bg-white rounded-xl shadow-sm overflow-hidden hover:shadow-md transition-shadow h-full">
            <div class="p-6">
              <div class="flex items-center space-x-2 mb-3">
                <span class="px-3 py-1 bg-primary-100 text-primary-700 rounded-full text-xs font-medium">
                  {{ article.category }}
                </span>
              </div>
              <h3 class="text-xl font-bold text-gray-900 group-hover:text-primary-600 transition-colors mb-2">
                {{ article.title }}
              </h3>
              <p class="text-gray-600 text-sm line-clamp-2 mb-4">
                {{ article.summary }}
              </p>
              <div class="flex items-center text-sm text-gray-500">
                <span>{{ article.author.username }}</span>
                <span class="mx-2">·</span>
                <span>{{ formatDate(article.createdAt) }}</span>
              </div>
            </div>
          </article>
        </router-link>
      </div>
    </section>
    
    <!-- Main Content -->
    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Articles List -->
      <div class="lg:col-span-2">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-bold text-gray-900">最新文章</h2>
          
          <!-- Category filter -->
          <select 
            v-model="selectedCategory"
            class="px-4 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          >
            <option value="">全部分类</option>
            <option v-for="cat in categories" :key="cat" :value="cat">
              {{ cat }}
            </option>
          </select>
        </div>
        
        <!-- Loading -->
        <div v-if="loading" class="space-y-4">
          <div v-for="i in 3" :key="i" class="bg-white rounded-xl p-6 animate-pulse">
            <div class="h-4 bg-gray-200 rounded w-20 mb-4"></div>
            <div class="h-6 bg-gray-200 rounded w-3/4 mb-3"></div>
            <div class="h-4 bg-gray-200 rounded w-full mb-2"></div>
            <div class="h-4 bg-gray-200 rounded w-2/3"></div>
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
            <p class="text-gray-500">暂无文章</p>
          </div>
        </div>
        
        <!-- Pagination -->
        <div v-if="pagination.totalPages > 1" class="mt-8 flex justify-center">
          <nav class="flex items-center space-x-2">
            <button 
              @click="changePage(pagination.page - 1)"
              :disabled="pagination.page === 0"
              class="p-2 rounded-lg border border-gray-300 hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            
            <button 
              v-for="page in visiblePages" 
              :key="page"
              @click="changePage(page)"
              class="px-4 py-2 rounded-lg transition-colors"
              :class="page === pagination.page 
                ? 'bg-primary-600 text-white' 
                : 'hover:bg-gray-100 text-gray-700'"
            >
              {{ page + 1 }}
            </button>
            
            <button 
              @click="changePage(pagination.page + 1)"
              :disabled="pagination.page >= pagination.totalPages - 1"
              class="p-2 rounded-lg border border-gray-300 hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
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
        <!-- Popular Articles -->
        <div class="bg-white rounded-xl shadow-sm p-6 mb-6">
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
                <span class="mx-2">·</span>
                <span>{{ article.likes }} 点赞</span>
              </div>
            </router-link>
          </div>
        </div>
        
        <!-- Categories -->
        <div class="bg-white rounded-xl shadow-sm p-6">
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
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useArticleStore } from '@/stores/article'
import ArticleCard from '@/components/ArticleCard.vue'

const articleStore = useArticleStore()

const loading = ref(true)
const selectedCategory = ref('')
const featuredArticles = ref([])

const articles = computed(() => articleStore.articles)
const popularArticles = computed(() => articleStore.popularArticles)
const categories = computed(() => articleStore.categories)
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

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    month: 'short',
    day: 'numeric'
  })
}

const loadArticles = async () => {
  loading.value = true
  await articleStore.fetchArticles({
    category: selectedCategory.value || undefined
  })
  loading.value = false
}

const changePage = (page) => {
  articleStore.setPage(page)
  loadArticles()
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

watch(selectedCategory, () => {
  articleStore.setPage(0)
  loadArticles()
})

onMounted(async () => {
  await Promise.all([
    loadArticles(),
    articleStore.fetchPopularArticles(),
    articleStore.fetchCategories()
  ])
  
  // Set featured articles (first 2)
  if (articles.value.length >= 2) {
    featuredArticles.value = articles.value.slice(0, 2)
  }
})
</script>
