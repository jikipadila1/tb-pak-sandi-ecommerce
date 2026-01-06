<template>
  <div class="orders">
    <div class="container mt-4">
      <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="mb-0"><i class="bi bi-bag-check me-2"></i>Pesanan Saya</h2>
        <div class="btn-group">
          <button
            v-for="status in statusFilters"
            :key="status.value"
            @click="filterStatus = status.value"
            class="btn btn-sm"
            :class="filterStatus === status.value ? 'btn-primary' : 'btn-outline-primary'"
          >
            {{ status.label }}
          </button>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Memuat...</span>
        </div>
      </div>

      <div v-else>
        <div v-if="filteredOrders.length === 0" class="text-center py-5">
          <i class="bi bi-bag-x" style="font-size: 4rem; color: #ccc;"></i>
          <h4 class="mt-3">{{ filterStatus ? 'Tidak ada pesanan dengan status ini' : 'Belum ada pesanan' }}</h4>
          <router-link to="/products" class="btn btn-primary mt-3">
            <i class="bi bi-shop me-2"></i>Mulai Belanja
          </router-link>
        </div>

        <div v-else>
          <div v-for="order in filteredOrders" :key="order.id" class="card mb-3 order-card">
            <div class="card-header bg-light">
              <div class="row align-items-center">
                <div class="col-md-3">
                  <strong><i class="bi bi-receipt me-2"></i>Pesanan #{{ order.id }}</strong>
                </div>
                <div class="col-md-3">
                  <span class="badge" :class="getStatusClass(order.status)">
                    {{ order.status.toUpperCase() }}
                  </span>
                </div>
                <div class="col-md-3 text-muted">
                  <i class="bi bi-calendar me-1"></i>
                  <small>{{ formatDate(order.created_at) }}</small>
                </div>
                <div class="col-md-3 text-end">
                  <strong class="text-primary h5 mb-0">{{ formatRupiah(order.total_amount) }}</strong>
                </div>
              </div>
            </div>

            <div class="card-body">
              <div class="row">
                <div class="col-md-8">
                  <h6 class="text-muted mb-3">Item Pesanan</h6>
                  <div class="order-items">
                    <div class="small text-muted">
                      <i class="bi bi-box me-2"></i>
                      {{ order.items?.length || 0 }} barang
                    </div>
                  </div>
                </div>

                <div class="col-md-4">
                  <h6 class="text-muted mb-3">Informasi Pengiriman</h6>
                  <div class="small">
                    <div class="mb-2">
                      <i class="bi bi-geo-alt me-2"></i>
                      <strong>Kota:</strong> {{ order.shipping_city || 'N/A' }}
                    </div>
                    <div class="mb-2">
                      <i class="bi bi-envelope me-2"></i>
                      <strong>Kode Pos:</strong> {{ order.shipping_postal_code || 'N/A' }}
                    </div>
                    <div class="mb-2">
                      <i class="bi bi-telephone me-2"></i>
                      <strong>Telepon:</strong> {{ order.shipping_phone || 'N/A' }}
                    </div>
                  </div>
                </div>
              </div>

              <div v-if="order.notes" class="alert alert-light mt-3 mb-0">
                <small><strong>Catatan:</strong> {{ order.notes }}</small>
              </div>
            </div>

            <div class="card-footer bg-white">
              <div class="d-flex justify-content-between align-items-center">
                <div>
                  <span class="text-muted small">
                    <i class="bi bi-clock me-1"></i>
                    Terakhir diperbarui: {{ formatDate(order.updated_at) }}
                  </span>
                </div>
                <div>
                  <router-link :to="`/orders/${order.id}`" class="btn btn-sm btn-outline-primary me-2">
                    <i class="bi bi-eye me-1"></i>Lihat Detail
                  </router-link>

                  <button
                    v-if="order.status === 'pending' || order.status === 'processing'"
                    @click="cancelOrder(order.id)"
                    class="btn btn-sm btn-danger"
                  >
                    <i class="bi bi-x-circle me-1"></i>Batalkan
                  </button>

                  <button
                    v-if="order.status === 'delivered'"
                    class="btn btn-sm btn-success"
                  >
                    <i class="bi bi-check-circle me-1"></i>Selesai
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import ordersApi from '../api/orders'
import { formatRupiah } from '../utils/currency'

export default {
  name: 'Orders',
  setup() {
    const orders = ref([])
    const loading = ref(true)
    const filterStatus = ref('')

    const statusFilters = [
      { value: '', label: 'Semua' },
      { value: 'pending', label: 'Menunggu' },
      { value: 'processing', label: 'Diproses' },
      { value: 'shipped', label: 'Dikirim' },
      { value: 'delivered', label: 'Terkirim' },
      { value: 'cancelled', label: 'Dibatalkan' }
    ]

    const filteredOrders = computed(() => {
      if (!filterStatus.value) return orders.value
      return orders.value.filter(order => order.status === filterStatus.value)
    })

    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
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

    const cancelOrder = async (orderId) => {
      if (!confirm('Apakah Anda yakin ingin membatalkan pesanan ini?')) return

      try {
        console.log('Orders: Cancelling order', orderId)
        const response = await ordersApi.cancel(orderId)
        console.log('Orders: Cancel response:', response.data)
        alert('Pesanan berhasil dibatalkan')
        fetchOrders()
      } catch (error) {
        console.error('Orders: Failed to cancel order:', error)
        console.error('Orders: Error details:', error.response?.data || error.message)
        alert(error.response?.data?.message || 'Gagal membatalkan pesanan')
      }
    }

    const fetchOrders = async () => {
      loading.value = true
      try {
        const response = await ordersApi.getAll()
        orders.value = response.data.data
      } catch (error) {
        console.error('Failed to fetch orders:', error)
        alert('Gagal memuat pesanan')
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      fetchOrders()
    })

    return {
      orders,
      loading,
      filterStatus,
      statusFilters,
      filteredOrders,
      formatDate,
      getStatusClass,
      cancelOrder,
      formatRupiah
    }
  }
}
</script>

<style scoped>
.order-card {
  transition: box-shadow 0.3s;
}

.order-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}
</style>
