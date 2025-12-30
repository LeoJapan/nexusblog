<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Main Content -->
      <div class="lg:col-span-2">
        <h1 class="text-3xl font-bold text-gray-900 mb-8">
          {{ tag }} - 标签下的文章
        </h1>
        
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
          <div v-if="articles.length === 0" class="text-center py-12 bg-white rounded-xl">
            <p class="text-gray-500">该标签下暂无文章</p>
          </div>
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
const tag = computed(() => route.params.tag)

const loadArticles = async () => {
  loading.value = true
  await articleStore.fetchArticles({
    tag: tag.value
  })
  loading.value = false
}

watch(tag, () => {
  loadArticles()
})

onMounted(async () => {
  await Promise.all([
    loadArticles(),
    articleStore.fetchCategories()
  ])
})
</script>
