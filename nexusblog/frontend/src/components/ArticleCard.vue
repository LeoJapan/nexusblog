<template>
  <article class="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-300 overflow-hidden">
    <!-- Article content -->
    <div class="p-6">
      <!-- Header -->
      <div class="flex items-start justify-between mb-4">
        <div class="flex-1">
          <!-- Categories -->
          <router-link 
            :to="`/category/${article.category}`"
            class="inline-block px-3 py-1 bg-primary-100 text-primary-700 rounded-full text-xs font-medium mb-2 hover:bg-primary-200"
          >
            {{ article.category }}
          </router-link>
          
          <!-- Title -->
          <router-link :to="`/article/${article.id}`">
            <h2 class="text-xl font-bold text-gray-900 hover:text-primary-600 transition-colors line-clamp-2">
              {{ article.title }}
            </h2>
          </router-link>
        </div>
      </div>
      
      <!-- Summary -->
      <p class="text-gray-600 text-sm line-clamp-3 mb-4">
        {{ article.summary }}
      </p>
      
      <!-- Tags -->
      <div v-if="article.tags" class="flex flex-wrap gap-2 mb-4">
        <router-link 
          v-for="tag in parseTags(article.tags)" 
          :key="tag"
          :to="`/tag/${tag}`"
          class="text-xs text-gray-500 hover:text-primary-600 bg-gray-100 px-2 py-1 rounded"
        >
          #{{ tag }}
        </router-link>
      </div>
      
      <!-- Meta info -->
      <div class="flex items-center justify-between text-sm text-gray-500">
        <div class="flex items-center space-x-4">
          <!-- Author -->
          <router-link 
            :to="`/user/${article.author.id}`"
            class="flex items-center space-x-2 hover:text-primary-600"
          >
            <div class="w-6 h-6 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
              <img 
                v-if="article.author.avatar" 
                :src="article.author.avatar" 
                :alt="article.author.username"
                class="w-full h-full object-cover"
              >
              <span v-else class="text-xs text-gray-500">
                {{ article.author.username.charAt(0).toUpperCase() }}
              </span>
            </div>
            <span>{{ article.author.username }}</span>
          </router-link>
          
          <!-- Date -->
          <span>{{ formatDate(article.createdAt) }}</span>
        </div>
        
        <div class="flex items-center space-x-4">
          <!-- Views -->
          <span class="flex items-center space-x-1">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
            </svg>
            <span>{{ article.views }}</span>
          </span>
          
          <!-- Likes -->
          <span class="flex items-center space-x-1">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
            <span>{{ article.likes }}</span>
          </span>
        </div>
      </div>
    </div>
  </article>
</template>

<script setup>
const props = defineProps({
  article: {
    type: Object,
    required: true
  }
})

const parseTags = (tagsString) => {
  if (!tagsString) return []
  return tagsString.split(',').map(tag => tag.trim()).filter(tag => tag)
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now - date
  
  // Less than 1 hour
  if (diff < 3600000) {
    const minutes = Math.floor(diff / 60000)
    return `${minutes}分钟前`
  }
  
  // Less than 24 hours
  if (diff < 86400000) {
    const hours = Math.floor(diff / 3600000)
    return `${hours}小时前`
  }
  
  // Less than 7 days
  if (diff < 604800000) {
    const days = Math.floor(diff / 86400000)
    return `${days}天前`
  }
  
  // Default format
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}
</script>
