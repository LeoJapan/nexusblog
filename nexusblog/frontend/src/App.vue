<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <NavBar />
    <main class="pt-16">
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>
    <FooterBar />
    <Toast />
  </div>
</template>

<script setup>
import NavBar from '@/components/NavBar.vue'
import FooterBar from '@/components/FooterBar.vue'
import Toast from '@/components/Toast.vue'
</script>
