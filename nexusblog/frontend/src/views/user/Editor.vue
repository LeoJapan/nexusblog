<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="grid lg:grid-cols-3 gap-8">
      <!-- Main Content -->
      <div class="lg:col-span-2">
        <h1 class="text-3xl font-bold text-gray-900 mb-8">写文章</h1>
        
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <!-- Title -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              标题 <span class="text-red-500">*</span>
            </label>
            <input 
              v-model="form.title"
              type="text"
              required
              maxlength="255"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="输入文章标题"
            >
            <p class="text-sm text-gray-500 mt-1">{{ form.title.length }}/255</p>
          </div>
          
          <!-- Category & Tags -->
          <div class="grid md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                分类 <span class="text-red-500">*</span>
              </label>
              <select 
                v-model="form.category"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              >
                <option value="">选择分类</option>
                <option v-for="cat in categories" :key="cat" :value="cat">
                  {{ cat }}
                </option>
                <option value="_new_">+ 新建分类</option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                标签
              </label>
              <input 
                v-model="form.tags"
                type="text"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
                placeholder="用逗号分隔标签"
              >
            </div>
          </div>
          
          <!-- New Category Input -->
          <div v-if="form.category === '_new_'" class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">
              新分类名称
            </label>
            <input 
              v-model="newCategory"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="输入新分类名称"
            >
          </div>
          
          <!-- Summary -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              摘要
            </label>
            <textarea 
              v-model="form.summary"
              rows="3"
              maxlength="500"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
              placeholder="文章摘要（可选）"
            ></textarea>
          </div>
          
          <!-- Content -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              内容 <span class="text-red-500">*</span>
            </label>
            <div class="border border-gray-300 rounded-xl overflow-hidden">
              <!-- Toolbar -->
              <div class="bg-gray-50 px-4 py-2 border-b flex items-center space-x-2">
                <button 
                  @click="insertMarkdown('**', '**')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="粗体"
                >
                  <span class="font-bold">B</span>
                </button>
                <button 
                  @click="insertMarkdown('*', '*')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="斜体"
                >
                  <span class="italic">I</span>
                </button>
                <button 
                  @click="insertMarkdown('# ', '')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="标题"
                >
                  H
                </button>
                <button 
                  @click="insertMarkdown('[', '](url)')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="链接"
                >
                  🔗
                </button>
                <button 
                  @click="insertMarkdown('`', '`')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="代码"
                >
                  &lt;/&gt;
                </button>
                <button 
                  @click="insertMarkdown('```\n', '\n```')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="代码块"
                >
                  ⌨
                </button>
                <button 
                  @click="insertMarkdown('- ', '')"
                  class="p-2 hover:bg-gray-200 rounded" 
                  title="列表"
                >
                  •
                </button>
              </div>
              
              <!-- Textarea -->
              <textarea 
                v-model="form.content"
                rows="15"
                required
                class="w-full px-4 py-3 focus:ring-0 focus:outline-none font-mono text-sm"
                placeholder="使用 Markdown 语法编写文章内容..."
              ></textarea>
            </div>
            <p class="text-sm text-gray-500 mt-1">
              支持 Markdown 语法：<code class="bg-gray-100 px-1 rounded">**粗体**</code>、<code class="bg-gray-100 px-1 rounded">*斜体*</code>、<code class="bg-gray-100 px-1 rounded"># 标题</code>等
            </p>
          </div>
          
          <!-- Actions -->
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <!-- Save as draft -->
              <button 
                type="button"
                @click="saveAsDraft"
                class="px-6 py-3 border border-gray-300 rounded-xl text-gray-700 hover:bg-gray-50 transition-colors"
              >
                保存草稿
              </button>
              
              <!-- Publish -->
              <button 
                type="submit"
                :disabled="loading"
                class="px-6 py-3 bg-primary-600 text-white rounded-xl hover:bg-primary-700 transition-colors disabled:opacity-50"
              >
                {{ loading ? '发布中...' : '发布文章' }}
              </button>
            </div>
            
            <!-- Preview -->
            <button 
              type="button"
              @click="showPreview = !showPreview"
              class="text-gray-600 hover:text-primary-600"
            >
              {{ showPreview ? '隐藏预览' : '显示预览' }}
            </button>
          </div>
        </form>
      </div>
      
      <!-- Sidebar -->
      <aside class="lg:col-span-1">
        <!-- Tips -->
        <div class="bg-primary-50 rounded-xl p-6 mb-6">
          <h3 class="font-bold text-primary-900 mb-3">写作提示</h3>
          <ul class="text-sm text-primary-800 space-y-2">
            <li>• 标题要简洁明了</li>
            <li>• 分类要准确</li>
            <li>• 使用合适的标签</li>
            <li>• 内容要有价值</li>
          </ul>
        </div>
        
        <!-- Preview Panel -->
        <div v-if="showPreview" class="bg-white rounded-xl shadow-sm p-6">
          <h3 class="font-bold text-gray-900 mb-4">预览</h3>
          <div class="prose prose-sm max-w-none">
            <h1>{{ form.title || '文章标题' }}</h1>
            <div v-if="form.summary" class="text-gray-600 mb-4">
              {{ form.summary }}
            </div>
            <div class="markdown-content" v-html="renderedPreview"></div>
          </div>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { marked } from 'marked'
import DOMPurify from 'dompurify'
import { useArticleStore } from '@/stores/article'
import { useToastStore } from '@/stores/toast'

const route = useRoute()
const router = useRouter()
const articleStore = useArticleStore()
const toastStore = useToastStore()

const loading = ref(false)
const showPreview = ref(false)
const newCategory = ref('')

const form = reactive({
  title: '',
  content: '',
  summary: '',
  category: '',
  tags: '',
  status: 'PUBLISHED'
})

const categories = computed(() => articleStore.categories)

const renderedPreview = computed(() => {
  if (!form.content) return ''
  const html = marked(form.content)
  return DOMPurify.sanitize(html)
})

const insertMarkdown = (prefix, suffix) => {
  const textarea = document.querySelector('textarea')
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const text = form.content
  const selectedText = text.substring(start, end)
  
  form.content = text.substring(0, start) + prefix + selectedText + suffix + text.substring(end)
  
  // Focus and set cursor position
  nextTick(() => {
    textarea.focus()
    textarea.setSelectionRange(
      start + prefix.length,
      end + prefix.length
    )
  })
}

const handleSubmit = async () => {
  if (!form.title.trim() || !form.content.trim() || !form.category) {
    toastStore.showError('请填写必填字段')
    return
  }
  
  loading.value = true
  
  try {
    // Handle new category
    let category = form.category
    if (category === '_new_') {
      if (!newCategory.value.trim()) {
        toastStore.showError('请输入新分类名称')
        loading.value = false
        return
      }
      category = newCategory.value.trim()
    }
    
    const data = {
      title: form.title.trim(),
      content: form.content.trim(),
      summary: form.summary.trim() || null,
      category,
      tags: form.tags.trim() || null,
      status: 'PUBLISHED'
    }
    
    let response
    if (route.params.id) {
      response = await articleStore.updateArticle(route.params.id, data)
    } else {
      response = await articleStore.createArticle(data)
    }
    
    if (response.success) {
      toastStore.showSuccess(route.params.id ? '文章更新成功' : '文章发布成功')
      router.push(`/article/${response.data.id}`)
    } else {
      toastStore.showError(response.error || '操作失败')
    }
  } catch (error) {
    toastStore.showError('操作失败')
  } finally {
    loading.value = false
  }
}

const saveAsDraft = async () => {
  loading.value = true
  
  try {
    let category = form.category
    if (category === '_new_') {
      if (!newCategory.value.trim()) {
        toastStore.showError('请输入新分类名称')
        loading.value = false
        return
      }
      category = newCategory.value.trim()
    }
    
    const data = {
      title: form.title.trim() || '无标题',
      content: form.content.trim(),
      summary: form.summary.trim() || null,
      category: category || '未分类',
      tags: form.tags.trim() || null,
      status: 'DRAFT'
    }
    
    let response
    if (route.params.id) {
      response = await articleStore.updateArticle(route.params.id, data)
    } else {
      response = await articleStore.createArticle(data)
    }
    
    if (response.success) {
      toastStore.showSuccess('草稿保存成功')
    }
  } catch (error) {
    toastStore.showError('保存失败')
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await articleStore.fetchCategories()
  
  // Load article for editing
  if (route.params.id) {
    const response = await articleStore.fetchArticleById(route.params.id)
    if (response?.success) {
      const article = response.data
      form.title = article.title
      form.content = article.content
      form.summary = article.summary || ''
      form.category = article.category
      form.tags = article.tags || ''
    }
  }
})
</script>
