<template>
  <div class="product-detail">
    <div class="container mt-4">
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><router-link to="/">Beranda</router-link></li>
          <li class="breadcrumb-item"><router-link to="/products">Produk</router-link></li>
          <li class="breadcrumb-item active" aria-current="page">{{ product?.name }}</li>
        </ol>
      </nav>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Loading...</span>
        </div>
      </div>

      <div v-else-if="product" class="row">
        <div class="col-md-6">
          <div class="card">
            <img
              :src="getProductImage(product.image)"
              :alt="product.name"
              class="card-img-top"
              style="object-fit: cover; height: 500px;"
            />
          </div>
        </div>

        <div class="col-md-6">
          <h1 class="h2">{{ product.name }}</h1>
          <p class="text-muted mb-3">
            <i class="bi bi-tag"></i> {{ product.category_name }}
          </p>

          <div class="mb-3">
            <h3 class="text-primary">{{ formatRupiah(product.price) }}</h3>
          </div>

          <div class="mb-4">
            <h5>Deskripsi</h5>
            <p class="text-muted">{{ product.description }}</p>
          </div>

          <div class="mb-4">
            <span class="badge" :class="stockClass">
              <i class="bi bi-box"></i> {{ stockText }}
            </span>
          </div>

          <div v-if="product.stock > 0" class="mb-4">
            <label class="form-label"><strong>Jumlah:</strong></label>
            <div class="input-group quantity-selector mb-3" style="max-width: 200px;">
              <button
                class="btn btn-outline-secondary btn-quantity"
                type="button"
                @click="decreaseQuantity"
                :disabled="quantity <= 1"
              >
                <i class="bi bi-dash"></i>
              </button>
              <input
                type="number"
                class="form-control text-center"
                v-model.number="quantity"
                min="1"
                :max="product.stock"
                @input="validateQuantity"
              />
              <button
                class="btn btn-outline-secondary btn-quantity"
                type="button"
                @click="increaseQuantity"
                :disabled="quantity >= product.stock"
              >
                <i class="bi bi-plus"></i>
              </button>
            </div>
          </div>

          <div class="d-grid gap-2">
            <button
              v-if="product.stock > 0"
              @click="addToCart"
              class="btn btn-primary btn-lg"
              :disabled="adding"
            >
              <span v-if="adding" class="spinner-border spinner-border-sm me-2"></span>
              <i v-else class="bi bi-cart-plus me-2"></i>
              {{ adding ? 'Menambahkan...' : 'Tambah ke Keranjang' }}
            </button>
            <button v-else class="btn btn-secondary btn-lg" disabled>
              Stok Habis
            </button>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-5">
        <h3>Produk tidak ditemukan</h3>
        <router-link to="/products" class="btn btn-primary mt-3">
          Lihat Produk
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProductsStore } from '../store/products'
import { useCartStore } from '../store/cart'
import { useAuthStore } from '../store/auth'
import { formatRupiah } from '../utils/currency'

export default {
  name: 'ProductDetail',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const productsStore = useProductsStore()
    const cartStore = useCartStore()
    const authStore = useAuthStore()

    const product = ref(null)
    const loading = ref(true)
    const quantity = ref(1)
    const adding = ref(false)

    const stockClass = computed(() => {
      if (!product.value) return 'bg-secondary'
      if (product.value.stock === 0) return 'bg-danger'
      if (product.value.stock < 10) return 'bg-warning'
      return 'bg-success'
    })

    const stockText = computed(() => {
      if (!product.value) return 'Memuat...'
      if (product.value.stock === 0) return 'Stok Habis'
      if (product.value.stock < 10) return `Tersisa ${product.value.stock} saja!`
      return `${product.value.stock} tersedia`
    })

    const validateQuantity = () => {
      if (quantity.value < 1) quantity.value = 1
      if (quantity.value > product.value.stock) quantity.value = product.value.stock
    }

    const increaseQuantity = () => {
      if (quantity.value < product.value.stock) {
        quantity.value++
      }
    }

    const decreaseQuantity = () => {
      if (quantity.value > 1) {
        quantity.value--
      }
    }

    const getProductImage = (imagePath) => {
      if (!imagePath) return 'https://via.placeholder.com/500x500?text=Tidak+Ada+Gambar'
      if (imagePath.startsWith('http')) return imagePath
      return `http://localhost/tbecommerce/public/uploads/products/${imagePath}`
    }

    const addToCart = async () => {
      if (!authStore.isAuthenticated) {
        if (confirm('Silakan login untuk menambahkan produk ke keranjang. Ke halaman login?')) {
          router.push('/login')
        }
        return
      }

      adding.value = true
      try {
        await cartStore.addToCart(product.value.id, quantity.value)
        alert(`${product.value.name} berhasil ditambahkan ke keranjang!`)
        quantity.value = 1
      } catch (error) {
        const errorMsg = error.response?.data?.message || 'Gagal menambahkan ke keranjang'
        alert(errorMsg)
      } finally {
        adding.value = false
      }
    }

    onMounted(async () => {
      try {
        product.value = await productsStore.fetchProductById(route.params.id)
      } catch (error) {
        console.error('Failed to load product:', error)
      } finally {
        loading.value = false
      }
    })

    return {
      product,
      loading,
      quantity,
      adding,
      stockClass,
      stockText,
      validateQuantity,
      increaseQuantity,
      decreaseQuantity,
      addToCart,
      formatRupiah,
      getProductImage
    }
  }
}
</script>

<style scoped>
.breadcrumb {
  background-color: #f8f9fa;
  padding: 0.75rem 1rem;
  border-radius: 0.25rem;
}

/* Custom styling for quantity buttons */
.quantity-selector {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  overflow: hidden;
}

.quantity-selector .btn-quantity {
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: bold;
  font-size: 1.2rem;
  min-width: 45px;
  height: 45px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.quantity-selector .btn-quantity:hover:not(:disabled) {
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
  transform: scale(1.1);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.quantity-selector .btn-quantity:active:not(:disabled) {
  transform: scale(0.95);
}

.quantity-selector .btn-quantity:disabled {
  background: #e9ecef;
  color: #6c757d;
  opacity: 0.6;
  cursor: not-allowed;
}

.quantity-selector .form-control {
  border: none;
  border-left: 2px solid #e9ecef;
  border-right: 2px solid #e9ecef;
  font-weight: 700;
  font-size: 1.25rem;
  color: #495057;
  background-color: white;
  height: 45px;
}

.quantity-selector .form-control:focus {
  border-color: #667eea;
  box-shadow: none;
  background-color: #f8f9ff;
}

/* Remove number input arrows/spinners */
.quantity-selector input[type="number"]::-webkit-outer-spin-button,
.quantity-selector input[type="number"]::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.quantity-selector input[type="number"] {
  -moz-appearance: textfield;
}

/* Add to Cart Button Enhancement */
.btn-primary.btn-lg {
  font-weight: 600;
  padding: 12px 24px;
  font-size: 1.1rem;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.btn-primary.btn-lg:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(13, 110, 253, 0.4);
}
</style>
