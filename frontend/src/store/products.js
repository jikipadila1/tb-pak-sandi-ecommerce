import { defineStore } from 'pinia'
import productsApi from '../api/products'
import categoriesApi from '../api/categories'

export const useProductsStore = defineStore('products', {
  state: () => ({
    products: [],
    categories: [],
    currentProduct: null,
    pagination: {},
    loading: false
  }),

  actions: {
    async fetchProducts(params = {}) {
      this.loading = true
      try {
        console.log('Store: Calling API with params:', params)
        const { data } = await productsApi.getAll(params)
        console.log('Store: API response:', data)
        this.products = data.data.products
        this.pagination = data.data.pagination
        console.log('Store: Products set to:', this.products.length, 'items')
      } catch (error) {
        console.error('Store: Failed to fetch products:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchProductById(id) {
      this.loading = true
      try {
        const { data } = await productsApi.getById(id)
        this.currentProduct = data.data
        return data.data
      } catch (error) {
        console.error('Failed to fetch product:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchProductBySlug(slug) {
      this.loading = true
      try {
        const { data } = await productsApi.getBySlug(slug)
        this.currentProduct = data.data
        return data.data
      } catch (error) {
        console.error('Failed to fetch product:', error)
        throw error
      } finally {
        this.loading = false
      }
    },

    async fetchProductsByCategory(categoryId, params = {}) {
      this.loading = true
      try {
        const { data } = await productsApi.getByCategory(categoryId, params)
        this.products = data.data.products
        this.pagination = data.data.pagination
      } catch (error) {
        console.error('Failed to fetch products:', error)
      } finally {
        this.loading = false
      }
    },

    async fetchCategories() {
      try {
        const { data } = await categoriesApi.getAll()
        this.categories = data.data
      } catch (error) {
        console.error('Failed to fetch categories:', error)
      }
    }
  }
})
