import { defineStore } from 'pinia'
import cartApi from '../api/cart'

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [],
    total: 0,
    loading: false
  }),

  getters: {
    itemCount: (state) => state.items.length,
    cartTotal: (state) => state.total
  },

  actions: {
    async fetchCart() {
      this.loading = true
      try {
        console.log('CartStore: Fetching cart...')
        const { data } = await cartApi.getCart()
        console.log('CartStore: API response:', data)
        this.items = data.data.items
        this.total = data.data.total
        console.log('CartStore: Items set to:', this.items.length, 'items, total:', this.total)
      } catch (error) {
        console.error('CartStore: Failed to fetch cart:', error)
        console.error('CartStore: Error details:', error.response?.data || error.message)
      } finally {
        this.loading = false
      }
    },

    async addToCart(productId, quantity = 1) {
      try {
        console.log('CartStore: Adding to cart, product:', productId, 'quantity:', quantity)
        const response = await cartApi.addToCart({ product_id: productId, quantity })
        console.log('CartStore: Add to cart response:', response.data)
        await this.fetchCart()
      } catch (error) {
        console.error('CartStore: Failed to add to cart:', error)
        console.error('CartStore: Error details:', error.response?.data || error.message)
        throw error
      }
    },

    async updateCartItem(cartItemId, quantity) {
      try {
        await cartApi.updateCart(cartItemId, { quantity })
        await this.fetchCart()
      } catch (error) {
        throw error
      }
    },

    async removeFromCart(cartItemId) {
      try {
        await cartApi.removeFromCart(cartItemId)
        await this.fetchCart()
      } catch (error) {
        throw error
      }
    },

    async clearCart() {
      try {
        await cartApi.clearCart()
        this.items = []
        this.total = 0
      } catch (error) {
        throw error
      }
    }
  }
})
