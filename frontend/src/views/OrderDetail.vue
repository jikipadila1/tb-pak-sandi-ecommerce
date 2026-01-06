<template>
  <div class="order-detail">
    <div class="container mt-4">
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
          <li class="breadcrumb-item"><router-link to="/">Home</router-link></li>
          <li class="breadcrumb-item"><router-link to="/orders">My Orders</router-link></li>
          <li class="breadcrumb-item active">Pesanan #{{ orderId }}</li>
        </ol>
      </nav>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status"></div>
      </div>

      <div v-else-if="order" class="row">
        <div class="col-md-8">
          <div class="card mb-4">
            <div class="card-header bg-primary text-white">
              <h5 class="mb-0">Pesanan #{{ order.id }}</h5>
            </div>
            <div class="card-body">
              <div class="row mb-3">
                <div class="col-md-6">
                  <h6>Tanggal Pesanan:</h6>
                  <p>{{ formatDate(order.created_at) }}</p>
                </div>
                <div class="col-md-6">
                  <h6>Status:</h6>
                  <span class="badge" :class="getStatusClass(order.status)">
                    {{ order.status.toUpperCase() }}
                  </span>
                </div>
              </div>

              <hr />

              <h6 class="mb-3">Informasi Pengiriman</h6>
              <p class="mb-1"><strong>Alamat:</strong> {{ order.shipping_address }}</p>
              <p class="mb-1"><strong>Kota:</strong> {{ order.shipping_city }}</p>
              <p class="mb-1"><strong>Kode Pos:</strong> {{ order.shipping_postal_code }}</p>
              <p class="mb-1"><strong>Telepon:</strong> {{ order.shipping_phone }}</p>

              <hr />

              <h6 class="mb-3">Item Pesanan</h6>
              <div class="table-responsive">
                <table class="table">
                  <thead>
                    <tr>
                      <th>Produk</th>
                      <th>Harga</th>
                      <th>Jumlah</th>
                      <th>Subtotal</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="item in order.items" :key="item.id">
                      <td>
                        <div class="d-flex align-items-center">
                          <img
                            :src="item.image || 'https://via.placeholder.com/50'"
                            :alt="item.name"
                            class="me-2 rounded"
                            style="width: 50px; height: 50px; object-fit: cover;"
                          />
                          <span>{{ item.name }}</span>
                        </div>
                      </td>
                      <td>{{ formatRupiah(item.price) }}</td>
                      <td>{{ item.quantity }}</td>
                      <td>{{ formatRupiah(item.subtotal) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="card">
            <div class="card-header bg-light">
              <h5 class="mb-0">Ringkasan Pesanan</h5>
            </div>
            <div class="card-body">
              <div class="d-flex justify-content-between mb-2">
                <span>Subtotal:</span>
                <span>{{ formatRupiah(order.total_amount) }}</span>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Pengiriman:</span>
                <span class="text-success">GRATIS</span>
              </div>
              <hr />
              <div class="d-flex justify-content-between mb-3">
                <strong>Total:</strong>
                <strong class="text-primary h5 mb-0">{{ formatRupiah(order.total_amount) }}</strong>
              </div>

              <router-link to="/orders" class="btn btn-outline-primary w-100">
                <i class="bi bi-arrow-left me-2"></i>Kembali ke Pesanan
              </router-link>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-5">
        <h3>Pesanan tidak ditemukan</h3>
        <router-link to="/orders" class="btn btn-primary mt-3">Lihat Semua Pesanan</router-link>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import ordersApi from '../api/orders'
import { formatRupiah } from '../utils/currency'

export default {
  name: 'OrderDetail',
  setup() {
    const route = useRoute()
    const orderId = route.params.id

    const order = ref(null)
    const loading = ref(true)

    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const getStatusClass = (status) => {
      const statusClasses = {
        pending: 'bg-warning text-dark',
        processing: 'bg-info',
        shipped: 'bg-primary',
        delivered: 'bg-success',
        cancelled: 'bg-danger'
      }
      return statusClasses[status] || 'bg-secondary'
    }

    const fetchOrderDetail = async () => {
      loading.value = true
      try {
        const response = await ordersApi.getById(orderId)
        order.value = response.data.data
      } catch (error) {
        console.error('Failed to fetch order:', error)
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      fetchOrderDetail()
    })

    return {
      orderId,
      order,
      loading,
      formatDate,
      getStatusClass,
      formatRupiah
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
</style>
