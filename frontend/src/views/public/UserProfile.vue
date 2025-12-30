<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- User Info -->
    <div class="bg-white rounded-xl shadow-sm overflow-hidden mb-8">
      <div class="p-8">
        <div class="flex items-start space-x-6">
          <!-- Avatar -->
          <div class="w-24 h-24 bg-gray-200 rounded-full flex items-center justify-center flex-shrink-0 overflow-hidden">
            <img 
              v-if="user.avatar" 
              :src="user.avatar" 
              :alt="user.username"
              class="w-full h-full object-cover"
            >
            <span v-else class="text-gray-500 text-3xl font-bold">
              {{ user.username.charAt(0).toUpperCase() }}
            </span>
          </div>
          
          <!-- Info -->
          <div class="flex-1">
            <h1 class="text-2xl font-bold text-gray-900 mb-2">
              {{ user.username }}
            </h1>
            <p class="text-gray-600 mb-4">
              {{ user.email }}
            </p>
            <div class="flex items-center space-x-6 text-sm text-gray-500">
              <span>
                <strong class="text-gray-900">{{ user.articleCount || 0 }}</strong> 篇文章
              </span>
              <span>
                <strong class="text-gray-900">{{ user.commentCount || 0 }}</strong> 条评论
              </span>
              <span>
                加入于 {{ formatDate(user.createdAt) }}
              </span>
            </div>
          </div>
          
          <!-- Edit button (own profile) -->
          <router-link 
            v-if="isOwnProfile"
            to="/profile"
            class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
          >
            编辑资料
          </router-link>
        </div>
      </div>
    </div>
    
    <!-- User's Articles -->
    <div>
      <h2 class="text-xl font-bold text-gray-900 mb-6">
        {{ isOwnProfile ? '我的文章' : 'TA的文章' }}
      </h2>
      
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
          <svg class="w-16 h-16 text-gray-300 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
          <p class="text-gray-500">
            {{ isOwnProfile ? '还没有发布过文章' : '该用户还没有发布过文章' }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useArticleStore } from '@/stores/article'
import { userApi } from '@/api/article'
import ArticleCard from '@/components/ArticleCard.vue'

const route = useRoute()
const userStore = useUserStore()
const articleStore = useArticleStore()

const loading = ref(true)
const user = ref({})

const isOwnProfile = computed(() => {
  return userStore.isAuthenticated && 
         userStore.userId === parseInt(route.params.id)
})

const articles = computed(() => articleStore.articles)

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const loadUser = async () => {
  try {
    const response = await userApi.getById(route.params.id)
    if (response.success) {
      user.value = response.data
    }
  } catch (error) {
    console.error('Failed to load user:', error)
  }
}

const loadArticles = async () => {
  try {
    await articleStore.fetchArticles({
      authorId: route.params.id
    })
  } catch (error) {
    console.error('Failed to load articles:', error)
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await Promise.all([
    loadUser(),
    loadArticles()
  ])
})
</script>
