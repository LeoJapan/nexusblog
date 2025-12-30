<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Loading -->
    <div v-if="loading" class="animate-pulse">
      <div class="h-8 bg-gray-200 rounded w-3/4 mb-4"></div>
      <div class="h-4 bg-gray-200 rounded w-1/4 mb-8"></div>
      <div class="h-64 bg-gray-200 rounded mb-8"></div>
      <div class="space-y-4">
        <div class="h-4 bg-gray-200 rounded w-full"></div>
        <div class="h-4 bg-gray-200 rounded w-5/6"></div>
        <div class="h-4 bg-gray-200 rounded w-4/6"></div>
      </div>
    </div>
    
    <!-- Article Content -->
    <article v-else-if="article">
      <!-- Header -->
      <header class="mb-8">
        <!-- Categories -->
        <router-link 
          :to="`/category/${article.category}`"
          class="inline-block px-3 py-1 bg-primary-100 text-primary-700 rounded-full text-sm font-medium mb-4"
        >
          {{ article.category }}
        </router-link>
        
        <!-- Title -->
        <h1 class="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
          {{ article.title }}
        </h1>
        
        <!-- Meta -->
        <div class="flex items-center text-gray-500 text-sm">
          <router-link 
            :to="`/user/${article.author.id}`"
            class="flex items-center hover:text-primary-600"
          >
            <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-2 overflow-hidden">
              <img 
                v-if="article.author.avatar" 
                :src="article.author.avatar" 
                :alt="article.author.username"
                class="w-full h-full object-cover"
              >
              <span v-else class="text-gray-500 text-sm">
                {{ article.author.username.charAt(0).toUpperCase() }}
              </span>
            </div>
            <span>{{ article.author.username }}</span>
          </router-link>
          
          <span class="mx-3">·</span>
          <span>{{ formatDate(article.createdAt) }}</span>
          <span class="mx-3">·</span>
          <span>{{ article.views }} 阅读</span>
        </div>
      </header>
      
      <!-- Tags -->
      <div v-if="article.tags" class="flex flex-wrap gap-2 mb-8">
        <router-link 
          v-for="tag in parseTags(article.tags)" 
          :key="tag"
          :to="`/tag/${tag}`"
          class="text-sm text-gray-500 hover:text-primary-600 bg-gray-100 px-3 py-1 rounded"
        >
          #{{ tag }}
        </router-link>
      </div>
      
      <!-- Content -->
      <div 
        class="markdown-content prose prose-lg max-w-none mb-8"
        v-html="renderedContent"
      ></div>
      
      <!-- Actions -->
      <div class="flex items-center justify-between border-t border-b py-4 mb-8">
        <div class="flex items-center space-x-4">
          <button 
            @click="handleLike"
            class="flex items-center space-x-2 px-4 py-2 rounded-lg hover:bg-gray-100 transition-colors"
            :class="{ 'text-primary-600': hasLiked }"
          >
            <svg class="w-5 h-5" :fill="hasLiked ? 'currentColor' : 'none'" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
            <span>{{ article.likes }}</span>
          </button>
          
          <button 
            @click="shareArticle"
            class="flex items-center space-x-2 px-4 py-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
            </svg>
            <span>分享</span>
          </button>
        </div>
        
        <router-link 
          v-if="isAuthor"
          :to="`/editor/${article.id}`"
          class="flex items-center space-x-2 px-4 py-2 rounded-lg hover:bg-gray-100 transition-colors"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
          </svg>
          <span>编辑</span>
        </router-link>
      </div>
      
      <!-- Author Info -->
      <div class="bg-gray-50 rounded-xl p-6 mb-8">
        <div class="flex items-start space-x-4">
          <router-link :to="`/user/${article.author.id}`">
            <div class="w-16 h-16 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
              <img 
                v-if="article.author.avatar" 
                :src="article.author.avatar" 
                :alt="article.author.username"
                class="w-full h-full object-cover"
              >
              <span v-else class="text-gray-500 text-xl font-bold">
                {{ article.author.username.charAt(0).toUpperCase() }}
              </span>
            </div>
          </router-link>
          <div class="flex-1">
            <router-link :to="`/user/${article.author.id}`" class="font-bold text-gray-900 hover:text-primary-600">
              {{ article.author.username }}
            </router-link>
            <p class="text-gray-600 text-sm mt-1">
              作者 · 加入于 {{ formatDate(article.author.createdAt) }}
            </p>
          </div>
        </div>
      </div>
      
      <!-- Comments Section -->
      <section>
        <h2 class="text-2xl font-bold text-gray-900 mb-6">
          评论 ({{ article.commentCount || 0 }})
        </h2>
        
        <!-- Comment Form -->
        <div v-if="isAuthenticated" class="mb-8">
          <textarea 
            v-model="newComment"
            rows="3"
            class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
            placeholder="写下你的评论..."
          ></textarea>
          <div class="flex justify-end mt-2">
            <button 
              @click="submitComment"
              class="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
              :disabled="!newComment.trim()"
            >
              发布评论
            </button>
          </div>
        </div>
        
        <div v-else class="bg-gray-50 rounded-xl p-6 mb-8 text-center">
          <p class="text-gray-600 mb-4">登录后可以发表评论</p>
          <router-link 
            to="/login"
            class="inline-block px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            登录
          </router-link>
        </div>
        
        <!-- Comments List -->
        <div class="space-y-4">
          <CommentItem 
            v-for="comment in comments" 
            :key="comment.id"
            :comment="comment"
            @like="handleCommentLike"
            @delete="handleCommentDelete"
            @reply="handleCommentReply"
          />
          
          <div v-if="comments.length === 0" class="text-center py-8 text-gray-500">
            暂无评论，快来抢沙发~
          </div>
        </div>
      </section>
    </article>
    
    <!-- Not Found -->
    <div v-else class="text-center py-16">
      <h2 class="text-2xl font-bold text-gray-900 mb-4">文章不存在</h2>
      <router-link to="/" class="text-primary-600 hover:underline">
        返回首页
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import { useArticleStore } from '@/stores/article'
import { useUserStore } from '@/stores/user'
import { useToastStore } from '@/stores/toast'
import { articleApi, commentApi } from '@/api/article'
import CommentItem from '@/components/CommentItem.vue'

const route = useRoute()
const router = useRouter()
const articleStore = useArticleStore()
const userStore = useUserStore()
const toastStore = useToastStore()

const loading = ref(true)
const article = ref(null)
const comments = ref([])
const newComment = ref('')
const hasLiked = ref(false)

const isAuthenticated = computed(() => userStore.isAuthenticated)
const isAuthor = computed(() => {
  if (!article.value || !userStore.user) return false
  return article.value.author.id === userStore.user.id
})

const renderedContent = computed(() => {
  if (!article.value?.content) return ''
  const html = marked(article.value.content)
  return DOMPurify.sanitize(html)
})

const parseTags = (tagsString) => {
  if (!tagsString) return []
  return tagsString.split(',').map(tag => tag.trim()).filter(tag => tag)
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

const loadArticle = async () => {
  loading.value = true
  const id = route.params.id
  
  const response = await articleStore.fetchArticleById(id)
  if (response?.success) {
    article.value = response.data
    // Fetch comments
    await loadComments()
  }
  loading.value = false
}

const loadComments = async () => {
  const id = route.params.id
  const response = await articleStore.fetchComments(id)
  if (response?.success) {
    comments.value = response.data
  }
}

const handleLike = async () => {
  try {
    const response = await articleApi.like(article.value.id)
    if (response.success) {
      article.value.likes = response.data.likes
      hasLiked.value = true
      toastStore.showSuccess('点赞成功')
    }
  } catch (error) {
    toastStore.showError('点赞失败')
  }
}

const shareArticle = () => {
  navigator.clipboard.writeText(window.location.href)
  toastStore.showSuccess('链接已复制到剪贴板')
}

const submitComment = async () => {
  if (!newComment.value.trim()) return
  
  try {
    const response = await articleStore.createComment({
      articleId: article.value.id,
      content: newComment.value.trim()
    })
    
    if (response.success) {
      newComment.value = ''
      await loadComments()
      toastStore.showSuccess('评论成功')
    }
  } catch (error) {
    toastStore.showError(error.response?.data?.error || '评论失败')
  }
}

const handleCommentLike = async (commentId) => {
  // TODO: Implement comment like
}

const handleCommentDelete = async (commentId) => {
  try {
    const response = await articleStore.deleteComment(commentId)
    if (response.success) {
      await loadComments()
      toastStore.showSuccess('评论已删除')
    }
  } catch (error) {
    toastStore.showError('删除失败')
  }
}

const handleCommentReply = async ({ parentId, content }) => {
  try {
    const response = await articleStore.createComment({
      articleId: article.value.id,
      content,
      parentId
    })
    
    if (response.success) {
      await loadComments()
      toastStore.showSuccess('回复成功')
    }
  } catch (error) {
    toastStore.showError('回复失败')
  }
}

onMounted(() => {
  loadArticle()
})
</script>
