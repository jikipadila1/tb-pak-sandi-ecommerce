<template>
  <div class="home">
    <div class="hero bg-primary text-white py-5 mb-4">
      <div class="container">
        <h1 class="display-4">Welcome to TB E-Commerce</h1>
        <p class="lead">Discover amazing products at great prices</p>
        <router-link to="/products" class="btn btn-light btn-lg">Shop Now</router-link>
      </div>
    </div>

    <div class="container">
      <h2 class="mb-4">Featured Products</h2>

      <div v-if="loading" class="text-center">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <div v-else-if="error" class="alert alert-danger">
        <strong>Error loading products:</strong><br>
        {{ error }}
      </div>

      <div v-else class="row">
        <div v-for="product in products" :key="product.id" class="col-md-3 mb-4">
          <ProductCard :product="product" />
        </div>

        <div v-if="products.length === 0" class="col-12 text-center">
          <p>No products available.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useProductsStore } from '../store/products'
import ProductCard from '../components/ProductCard.vue'

export default {
  name: 'Home',
  components: {
    ProductCard
  },
  setup() {
    const productsStore = useProductsStore()
    const products = ref([])
    const loading = ref(true)
    const error = ref(null)

    onMounted(async () => {
      try {
        console.log('Home: Fetching products...')
        await productsStore.fetchProducts({ per_page: 8 })
        products.value = productsStore.products
        console.log('Home: Products loaded:', products.value.length)
      } catch (err) {
        console.error('Failed to load products:', err)
        error.value = err.response?.data?.message || err.message || 'Failed to connect to server'
      } finally {
        loading.value = false
      }
    })

    return {
      products,
      loading,
      error
    }
  }
}
</script>

<style scoped>
.hero {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
</style>
