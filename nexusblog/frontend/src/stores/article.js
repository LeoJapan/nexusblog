import { defineStore } from 'pinia'
import { articleApi, commentApi } from '@/api/article'

export const useArticleStore = defineStore('article', {
  state: () => ({
    articles: [],
    currentArticle: null,
    popularArticles: [],
    categories: [],
    pagination: {
      page: 0,
      size: 10,
      totalElements: 0,
      totalPages: 0
    },
    loading: false,
    comments: []
  }),
  
  actions: {
    async fetchArticles(params = {}) {
      this.loading = true
      try {
        const response = await articleApi.getList({
          page: this.pagination.page,
          size: this.pagination.size,
          ...params
        })
        
        if (response.success) {
          this.articles = response.data.content
          this.pagination = {
            page: response.data.page,
            size: response.data.size,
            totalElements: response.data.totalElements,
            totalPages: response.data.totalPages
          }
        }
      } catch (error) {
        console.error('Failed to fetch articles:', error)
      } finally {
        this.loading = false
      }
    },
    
    async fetchArticleById(id) {
      this.loading = true
      try {
        const response = await articleApi.getById(id)
        if (response.success) {
          this.currentArticle = response.data
        }
        return response
      } catch (error) {
        console.error('Failed to fetch article:', error)
        return null
      } finally {
        this.loading = false
      }
    },
    
    async createArticle(data) {
      try {
        const response = await articleApi.create(data)
        return response
      } catch (error) {
        throw error
      }
    },
    
    async updateArticle(id, data) {
      try {
        const response = await articleApi.update(id, data)
        return response
      } catch (error) {
        throw error
      }
    },
    
    async deleteArticle(id) {
      try {
        const response = await articleApi.delete(id)
        return response
      } catch (error) {
        throw error
      }
    },
    
    async fetchPopularArticles() {
      try {
        const response = await articleApi.getPopular(5)
        if (response.success) {
          this.popularArticles = response.data
        }
      } catch (error) {
        console.error('Failed to fetch popular articles:', error)
      }
    },
    
    async fetchCategories() {
      try {
        const response = await articleApi.getCategories()
        if (response.success) {
          this.categories = response.data
        }
      } catch (error) {
        console.error('Failed to fetch categories:', error)
      }
    },
    
    async fetchComments(articleId) {
      try {
        const response = await commentApi.getByArticle(articleId)
        if (response.success) {
          this.comments = response.data
        }
        return response
      } catch (error) {
        console.error('Failed to fetch comments:', error)
        return null
      }
    },
    
    async createComment(data) {
      try {
        const response = await commentApi.create(data)
        return response
      } catch (error) {
        throw error
      }
    },
    
    async deleteComment(id) {
      try {
        const response = await commentApi.delete(id)
        return response
      } catch (error) {
        throw error
      }
    },
    
    setPage(page) {
      this.pagination.page = page
    },
    
    clearCurrentArticle() {
      this.currentArticle = null
      this.comments = []
    }
  }
})
