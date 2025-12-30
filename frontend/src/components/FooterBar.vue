<template>
  <footer class="bg-white border-t mt-auto">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <!-- About -->
        <div>
          <div class="flex items-center space-x-2 mb-4">
            <div class="w-8 h-8 bg-gradient-to-br from-primary-500 to-primary-700 rounded-lg flex items-center justify-center">
              <span class="text-white font-bold text-lg">N</span>
            </div>
            <span class="text-xl font-bold text-gray-900">NexusBlog</span>
          </div>
          <p class="text-gray-600 text-sm">
            一个现代化的全栈博客系统，支持用户发布、阅读和互动博客文章。
          </p>
        </div>
        
        <!-- Quick Links -->
        <div>
          <h3 class="text-sm font-semibold text-gray-900 mb-4">快速链接</h3>
          <div class="space-y-2">
            <router-link to="/" class="block text-gray-600 hover:text-primary-600 text-sm">
              首页
            </router-link>
            <router-link to="/search" class="block text-gray-600 hover:text-primary-600 text-sm">
              搜索
            </router-link>
            <a href="#" class="block text-gray-600 hover:text-primary-600 text-sm">
              关于我们
            </a>
            <a href="#" class="block text-gray-600 hover:text-primary-600 text-sm">
              联系我们
            </a>
          </div>
        </div>
        
        <!-- Tech Stack -->
        <div>
          <h3 class="text-sm font-semibold text-gray-900 mb-4">技术栈</h3>
          <div class="flex flex-wrap gap-2">
            <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs">
              Vue 3
            </span>
            <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs">
              Spring Boot
            </span>
            <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs">
              MySQL
            </span>
            <span class="px-3 py-1 bg-gray-100 text-gray-700 rounded-full text-xs">
              JWT
            </span>
          </div>
        </div>
      </div>
      
      <!-- Copyright -->
      <div class="border-t mt-8 pt-8 text-center text-sm text-gray-500">
        <p>&copy; {{ currentYear }} NexusBlog. All rights reserved.</p>
      </div>
    </div>
  </footer>
</template>

<script setup>
const currentYear = new Date().getFullYear()
</script>
