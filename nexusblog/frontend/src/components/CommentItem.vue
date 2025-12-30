<template>
  <div class="bg-white rounded-xl shadow-sm overflow-hidden">
    <!-- Comment content -->
    <div class="p-4">
      <!-- Header -->
      <div class="flex items-start space-x-3">
        <!-- Avatar -->
        <router-link :to="`/user/${comment.user.id}`" class="flex-shrink-0">
          <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
            <img 
              v-if="comment.user.avatar" 
              :src="comment.user.avatar" 
              :alt="comment.user.username"
              class="w-full h-full object-cover"
            >
            <span v-else class="text-gray-500 font-medium">
              {{ comment.user.username.charAt(0).toUpperCase() }}
            </span>
          </div>
        </router-link>
        
        <!-- Content -->
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between mb-1">
            <router-link 
              :to="`/user/${comment.user.id}`"
              class="font-medium text-gray-900 hover:text-primary-600"
            >
              {{ comment.user.username }}
            </router-link>
            <span class="text-sm text-gray-500">{{ formatDate(comment.createdAt) }}</span>
          </div>
          
          <!-- Reply target -->
          <div v-if="comment.parentId" class="text-sm text-gray-500 mb-2">
            回复 <span class="text-primary-600">@{{ comment.parentUsername || '用户' }}</span>
          </div>
          
          <!-- Comment text -->
          <p class="text-gray-700">{{ comment.content }}</p>
          
          <!-- Actions -->
          <div class="flex items-center space-x-4 mt-3">
            <button 
              @click="handleLike"
              class="text-sm text-gray-500 hover:text-primary-600 flex items-center space-x-1"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
              </svg>
              <span>点赞</span>
            </button>
            
            <button 
              v-if="isAuthenticated"
              @click="showReplyForm = !showReplyForm"
              class="text-sm text-gray-500 hover:text-primary-600 flex items-center space-x-1"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6" />
              </svg>
              <span>回复</span>
            </button>
            
            <button 
              v-if="canDelete"
              @click="$emit('delete', comment.id)"
              class="text-sm text-gray-500 hover:text-red-600 flex items-center space-x-1"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
              <span>删除</span>
            </button>
          </div>
          
          <!-- Reply form -->
          <transition name="slide-up">
            <div v-if="showReplyForm" class="mt-3">
              <textarea 
                v-model="replyContent"
                rows="2"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500 text-sm"
                placeholder="写下你的回复..."
              ></textarea>
              <div class="flex justify-end space-x-2 mt-2">
                <button 
                  @click="showReplyForm = false"
                  class="px-3 py-1 text-sm text-gray-600 hover:text-gray-800"
                >
                  取消
                </button>
                <button 
                  @click="submitReply"
                  class="px-3 py-1 text-sm bg-primary-600 text-white rounded-lg hover:bg-primary-700"
                  :disabled="!replyContent.trim()"
                >
                  发布回复
                </button>
              </div>
            </div>
          </transition>
        </div>
      </div>
    </div>
    
    <!-- Nested replies -->
    <div v-if="comment.replies && comment.replies.length > 0" class="bg-gray-50 px-4 py-2">
      <CommentItem 
        v-for="reply in comment.replies" 
        :key="reply.id"
        :comment="reply"
        :parent-username="comment.user.username"
        @like="$emit('like', $event)"
        @delete="$emit('delete', $event)"
        @reply="$emit('reply', $event)"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useUserStore } from '@/stores/user'

const props = defineProps({
  comment: {
    type: Object,
    required: true
  },
  parentUsername: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['like', 'delete', 'reply'])

const userStore = useUserStore()
const showReplyForm = ref(false)
const replyContent = ref('')

const isAuthenticated = computed(() => userStore.isAuthenticated)
const canDelete = computed(() => {
  if (!isAuthenticated.value) return false
  const currentUserId = userStore.userId
  return props.comment.user.id === currentUserId || userStore.isAdmin
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

const handleLike = () => {
  emit('like', props.comment.id)
}

const submitReply = () => {
  if (!replyContent.value.trim()) return
  
  emit('reply', {
    parentId: props.comment.id,
    content: replyContent.value
  })
  
  replyContent.value = ''
  showReplyForm.value = false
}
</script>
