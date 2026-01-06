<template>
  <div class="card h-100 product-card">
    <div class="image-container">
      <img :src="getProductImage(product.image)" class="card-img-top" :alt="product.name" />
    </div>
    <div class="card-body d-flex flex-column">
      <h5 class="card-title">{{ product.name }}</h5>
      <p class="card-text text-muted small">{{ product.category_name }}</p>
      <p class="card-text">{{ truncateDescription(product.description) }}</p>
      <div class="mt-auto">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <span class="h5 mb-0 text-primary">{{ formatRupiah(product.price) }}</span>
          <span class="badge bg-secondary">Stok: {{ product.stock }}</span>
        </div>
        <router-link :to="'/products/' + product.id" class="btn btn-primary w-100 mt-2">
          <i class="bi bi-eye me-1"></i>Lihat Detail
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { formatRupiah } from '../utils/currency'

export default {
  name: 'ProductCard',
  props: {
    product: {
      type: Object,
      required: true
    }
  },
  methods: {
    formatRupiah,
    truncateDescription(text) {
      if (!text) return ''
      return text.length > 100 ? text.substring(0, 100) + '...' : text
    },
    getProductImage(imagePath) {
      if (!imagePath) return 'https://via.placeholder.com/400x300?text=Tidak+Ada+Gambar'
      if (imagePath.startsWith('http')) return imagePath
      return `http://localhost/tbecommerce/public/uploads/products/${imagePath}`
    }
  }
}
</script>

<style scoped>
.product-card {
  transition: all 0.3s ease;
  border: 1px solid #e0e0e0;
  overflow: hidden;
}

.product-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
}

.image-container {
  height: 200px;
  overflow: hidden;
  background-color: #f8f9fa;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.product-card:hover .image-container img {
  transform: scale(1.1);
}
</style>
