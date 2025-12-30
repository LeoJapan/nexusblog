import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

// Public routes
const publicRoutes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('@/views/public/Home.vue'),
    meta: { title: '首页' }
  },
  {
    path: '/article/:id',
    name: 'ArticleDetail',
    component: () => import('@/views/public/ArticleDetail.vue'),
    meta: { title: '文章详情' }
  },
  {
    path: '/category/:category',
    name: 'Category',
    component: () => import('@/views/public/Category.vue'),
    meta: { title: '分类浏览' }
  },
  {
    path: '/tag/:tag',
    name: 'Tag',
    component: () => import('@/views/public/Tag.vue'),
    meta: { title: '标签浏览' }
  },
  {
    path: '/search',
    name: 'Search',
    component: () => import('@/views/public/Search.vue'),
    meta: { title: '搜索' }
  },
  {
    path: '/user/:id',
    name: 'UserProfile',
    component: () => import('@/views/public/UserProfile.vue'),
    meta: { title: '用户主页' }
  }
]

// Auth routes (for guests only)
const authRoutes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/Login.vue'),
    meta: { title: '登录', guest: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/auth/Register.vue'),
    meta: { title: '注册', guest: true }
  }
]

// Protected routes (require authentication)
const protectedRoutes = [
  {
    path: '/editor',
    name: 'Editor',
    component: () => import('@/views/user/Editor.vue'),
    meta: { title: '写文章', requiresAuth: true }
  },
  {
    path: '/editor/:id',
    name: 'EditorEdit',
    component: () => import('@/views/user/Editor.vue'),
    meta: { title: '编辑文章', requiresAuth: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/views/user/Profile.vue'),
    meta: { title: '个人资料', requiresAuth: true }
  },
  {
    path: '/my-articles',
    name: 'MyArticles',
    component: () => import('@/views/user/MyArticles.vue'),
    meta: { title: '我的文章', requiresAuth: true }
  }
]

// Admin routes
const adminRoutes = [
  {
    path: '/admin',
    name: 'AdminDashboard',
    component: () => import('@/views/admin/Dashboard.vue'),
    meta: { title: '管理后台', requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/articles',
    name: 'AdminArticles',
    component: () => import('@/views/admin/ArticleManagement.vue'),
    meta: { title: '文章管理', requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/users',
    name: 'AdminUsers',
    component: () => import('@/views/admin/UserManagement.vue'),
    meta: { title: '用户管理', requiresAuth: true, requiresAdmin: true }
  },
  {
    path: '/admin/comments',
    name: 'AdminComments',
    component: () => import('@/views/admin/CommentManagement.vue'),
    meta: { title: '评论管理', requiresAuth: true, requiresAdmin: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes: [
    ...publicRoutes,
    ...authRoutes,
    ...protectedRoutes,
    ...adminRoutes
  ],
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { top: 0 }
    }
  }
})

// Navigation guards
router.beforeEach((to, from, next) => {
  // Set page title
  document.title = `${to.meta.title || 'NexusBlog'} - NexusBlog`
  
  const userStore = useUserStore()
  const isAuthenticated = userStore.isAuthenticated
  const isAdmin = userStore.isAdmin
  
  // Guest only routes
  if (to.meta.guest && isAuthenticated) {
    next({ name: 'Home' })
    return
  }
  
  // Protected routes
  if (to.meta.requiresAuth && !isAuthenticated) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
    return
  }
  
  // Admin routes
  if (to.meta.requiresAdmin && !isAdmin) {
    next({ name: 'Home' })
    return
  }
  
  next()
})

export default router
