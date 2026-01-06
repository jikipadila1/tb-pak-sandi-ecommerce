<template>
  <div class="products">
    <div class="container mt-4">
      <h2 class="mb-4">All Products</h2>

      <div class="row">
        <div class="col-md-3">
          <div class="card">
            <div class="card-body">
              <h5 class="card-title">Categories</h5>
              <div class="list-group">
                <button
                  @click="filterByCategory(null)"
                  class="list-group-item list-group-item-action"
                  :class="{ active: selectedCategory === null }"
                >
                  All Products
                </button>
                <button
                  v-for="category in categories"
                  :key="category.id"
                  @click="filterByCategory(category.id)"
                  class="list-group-item list-group-item-action"
                  :class="{ active: selectedCategory === category.id }"
                >
                  {{ category.name }} ({{ category.product_count }})
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-9">
          <div v-if="loading" class="text-center">
            <div class="spinner-border" role="status">
              <span class="visually-hidden">Loading...</span>
            </div>
          </div>

          <div v-else-if="error" class="alert alert-danger">
            <strong>Error loading products:</strong><br>
            {{ error }}
          </div>

          <div v-else>
            <div class="row">
              <div v-for="product in products" :key="product.id" class="col-md-4 mb-4">
                <ProductCard :product="product" />
              </div>
            </div>

            <div v-if="products.length === 0" class="text-center">
              <p>No products found.</p>
            </div>

            <nav v-if="pagination.total_pages > 1" class="mt-4">
              <ul class="pagination justify-content-center">
                <li class="page-item" :class="{ disabled: pagination.current_page === 1 }">
                  <a class="page-link" @click="changePage(pagination.current_page - 1)">Previous</a>
                </li>
                <li
                  v-for="page in pagination.total_pages"
                  :key="page"
                  class="page-item"
                  :class="{ active: pagination.current_page === page }"
                >
                  <a class="page-link" @click="changePage(page)">{{ page }}</a>
                </li>
                <li class="page-item" :class="{ disabled: pagination.current_page === pagination.total_pages }">
                  <a class="page-link" @click="changePage(pagination.current_page + 1)">Next</a>
                </li>
              </ul>
            </nav>
          </div>
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
  name: 'Products',
  components: {
    ProductCard
  },
  setup() {
    const productsStore = useProductsStore()
    const products = ref([])
    const categories = ref([])
    const pagination = ref({})
    const loading = ref(true)
    const selectedCategory = ref(null)
    const error = ref(null)

    const loadProducts = async (params = {}) => {
      loading.value = true
      error.value = null
      try {
        if (selectedCategory.value) {
          await productsStore.fetchProductsByCategory(selectedCategory.value, params)
        } else {
          await productsStore.fetchProducts(params)
        }
        products.value = productsStore.products
        pagination.value = productsStore.pagination
        console.log('Products loaded:', products.value.length)
      } catch (err) {
        console.error('Failed to load products:', err)
        error.value = err.response?.data?.message || err.message || 'Failed to connect to server'
      } finally {
        loading.value = false
      }
    }

    const filterByCategory = (categoryId) => {
      selectedCategory.value = categoryId
      loadProducts()
    }

    const changePage = (page) => {
      if (page >= 1 && page <= pagination.value.total_pages) {
        loadProducts({ page })
      }
    }

    onMounted(async () => {
      await productsStore.fetchCategories()
      categories.value = productsStore.categories
      await loadProducts()
    })

    return {
      products,
      categories,
      pagination,
      loading,
      error,
      selectedCategory,
      filterByCategory,
      changePage
    }
  }
}
</script>
