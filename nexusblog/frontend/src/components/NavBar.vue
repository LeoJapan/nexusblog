<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-white shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center h-16">
        <!-- Logo -->
        <router-link to="/" class="flex items-center space-x-2">
          <div class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center">
            <span class="text-white font-bold text-lg">N</span>
          </div>
          <span class="text-xl font-bold text-gray-900">NexusBlog</span>
        </router-link>
        
        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center space-x-8">
          <router-link 
            to="/" 
            class="text-gray-600 hover:text-primary-600 transition-colors"
            :class="{ 'text-primary-600 font-medium': $route.name === 'Home' }"
          >
            首页
          </router-link>
          
          <!-- Categories dropdown -->
          <div class="relative group">
            <button class="text-gray-600 hover:text-primary-600 transition-colors flex items-center space-x-1">
              <span>分类</span>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            <div class="absolute left-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200">
              <router-link 
                v-for="category in categories" 
                :key="category"
                :to="`/category/${category}`"
                class="block px-4 py-2 text-gray-700 hover:bg-gray-100"
              >
                {{ category }}
              </router-link>
            </div>
          </div>
          
          <router-link 
            to="/search" 
            class="text-gray-600 hover:text-primary-600 transition-colors"
            :class="{ 'text-primary-600 font-medium': $route.name === 'Search' }"
          >
            搜索
          </router-link>
        </div>
        
        <!-- User section -->
        <div class="flex items-center space-x-4">
          <router-link 
            v-if="!isAuthenticated"
            to="/login"
            class="text-gray-600 hover:text-primary-600 transition-colors"
          >
            登录
          </router-link>
          
          <router-link 
            v-if="!isAuthenticated"
            to="/register"
            class="bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition-colors"
          >
            注册
          </router-link>
          
          <!-- Authenticated user menu -->
          <div v-if="isAuthenticated" class="relative group">
            <button class="flex items-center space-x-2 text-gray-700 hover:text-primary-600">
              <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden">
                <img 
                  v-if="user.avatar" 
                  :src="user.avatar" 
                  :alt="user.username"
                  class="w-full h-full object-cover"
                >
                <span v-else class="text-gray-500 font-medium">
                  {{ user.username.charAt(0).toUpperCase() }}
                </span>
              </div>
              <span class="hidden sm:block">{{ user.username }}</span>
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
            
            <div class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200">
              <router-link to="/editor" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                </svg>
                写文章
              </router-link>
              <router-link to="/my-articles" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                我的文章
              </router-link>
              <router-link to="/profile" class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100">
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
                个人资料
              </router-link>
              <router-link 
                v-if="isAdmin" 
                to="/admin" 
                class="flex items-center px-4 py-2 text-gray-700 hover:bg-gray-100"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                管理后台
              </router-link>
              <hr class="my-2">
              <button 
                @click="handleLogout"
                class="flex items-center w-full px-4 py-2 text-gray-700 hover:bg-gray-100"
              >
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                退出登录
              </button>
            </div>
          </div>
          
          <!-- Mobile menu button -->
          <button 
            @click="mobileMenuOpen = !mobileMenuOpen"
            class="md:hidden p-2 rounded-lg hover:bg-gray-100"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path v-if="!mobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
    </div>
    
    <!-- Mobile menu -->
    <transition name="slide-up">
      <div v-if="mobileMenuOpen" class="md:hidden bg-white border-t">
        <div class="px-4 py-3 space-y-2">
          <router-link 
            to="/" 
            class="block px-4 py-2 rounded-lg text-gray-700 hover:bg-gray-100"
            @click="mobileMenuOpen = false"
          >
            首页
          </router-link>
          <router-link 
            to="/search" 
            class="block px-4 py-2 rounded-lg text-gray-700 hover:bg-gray-100"
            @click="mobileMenuOpen = false"
          >
            搜索
          </router-link>
          <template v-if="!isAuthenticated">
            <router-link 
              to="/login" 
              class="block px-4 py-2 rounded-lg text-gray-700 hover:bg-gray-100"
              @click="mobileMenuOpen = false"
            >
              登录
            </router-link>
            <router-link 
              to="/register" 
              class="block px-4 py-2 rounded-lg text-primary-600 hover:bg-gray-100"
              @click="mobileMenuOpen = false"
            >
              注册
            </router-link>
          </template>
          <template v-else>
            <router-link 
              to="/editor" 
              class="block px-4 py-2 rounded-lg text-gray-700 hover:bg-gray-100"
              @click="mobileMenuOpen = false"
            >
              写文章
            </router-link>
            <router-link 
              to="/profile" 
              class="block px-4 py-2 rounded-lg text-gray-700 hover:bg-gray-100"
              @click="mobileMenuOpen = false"
            >
              个人资料
            </router-link>
            <button 
              @click="handleLogout"
              class="block w-full text-left px-4 py-2 rounded-lg text-gray-700 hover:bg-gray-100"
            >
              退出登录
            </button>
          </template>
        </div>
      </div>
    </transition>
  </nav>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useArticleStore } from '@/stores/article'

const router = useRouter()
const userStore = useUserStore()
const articleStore = useArticleStore()

const mobileMenuOpen = ref(false)
const categories = ref([])

const isAuthenticated = userStore.isAuthenticated
const isAdmin = userStore.isAdmin
const user = userStore.user

const handleLogout = () => {
  userStore.logout()
  mobileMenuOpen.value = false
  router.push('/')
}

onMounted(() => {
  articleStore.fetchCategories().then(() => {
    categories.value = articleStore.categories
  })
})
</script>
