import api from './index'

// Authentication APIs
export const authApi = {
  register(data) {
    return api.post('/auth/register', data)
  },
  
  login(data) {
    return api.post('/auth/login', data)
  },
  
  getCurrentUser() {
    return api.get('/auth/me')
  }
}

// Article APIs
export const articleApi = {
  getList(params) {
    return api.get('/articles', { params })
  },
  
  getById(id) {
    return api.get(`/articles/${id}`)
  },
  
  create(data) {
    return api.post('/articles', data)
  },
  
  update(id, data) {
    return api.put(`/articles/${id}`, data)
  },
  
  delete(id) {
    return api.delete(`/articles/${id}`)
  },
  
  getByAuthor(authorId, params) {
    return api.get(`/articles/author/${authorId}`, { params })
  },
  
  getPopular(limit = 5) {
    return api.get('/articles/popular', { params: { limit } })
  },
  
  getCategories() {
    return api.get('/articles/categories')
  },
  
  like(id) {
    return api.post(`/articles/${id}/like`)
  }
}

// Comment APIs
export const commentApi = {
  getByArticle(articleId) {
    return api.get(`/comments/article/${articleId}`)
  },
  
  create(data) {
    return api.post('/comments', data)
  },
  
  delete(id) {
    return api.delete(`/comments/${id}`)
  },
  
  approve(id) {
    return api.put(`/comments/admin/${id}/approve`)
  }
}

// User APIs
export const userApi = {
  getById(id) {
    return api.get(`/users/${id}`)
  },
  
  updateProfile(data) {
    return api.put('/users/profile', data)
  },
  
  getAll(params) {
    return api.get('/users/admin/all', { params })
  },
  
  updateStatus(id, status) {
    return api.put(`/users/admin/${id}/status`, null, { params: { status } })
  }
}

// Admin APIs
export const adminApi = {
  getStats() {
    return api.get('/admin/stats')
  },
  
  getPendingArticles(params) {
    return api.get('/admin/articles/pending', { params })
  },
  
  getAllArticles(params) {
    return api.get('/admin/articles/all', { params })
  },
  
  auditArticle(id, action) {
    return api.put(`/admin/articles/${id}/audit`, null, { params: { action } })
  },
  
  getAllUsers(params) {
    return api.get('/users/admin/all', { params })
  },
  
  banUser(id, status) {
    return api.put(`/users/admin/${id}/status`, null, { params: { status } })
  },
  
  getAllComments(params) {
    return api.get('/comments/admin/all', { params })
  }
}
