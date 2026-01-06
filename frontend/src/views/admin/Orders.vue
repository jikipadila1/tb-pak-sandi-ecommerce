<template>
  <AdminLayout>
    <!-- Page Header -->
    <div class="page-header">
      <div>
        <h1 class="page-title">
          <i class="bi bi-bag-check me-2"></i>Manajemen Pesanan
        </h1>
        <p class="page-subtitle">Kelola semua pesanan customer</p>
      </div>
      <div class="header-actions">
        <button class="btn btn-outline-primary" @click="fetchOrders">
          <i class="bi bi-arrow-repeat me-2"></i>Refresh
        </button>
        <button class="btn btn-primary">
          <i class="bi bi-download me-2"></i>Export
        </button>
      </div>
    </div>

    <!-- Statistics Cards -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-content">
          <div class="stat-info">
            <p class="stat-label">Total Pesanan</p>
            <h2 class="stat-value">{{ stats.total }}</h2>
            <div class="stat-change positive">
              <i class="bi bi-arrow-up"></i>
              <span>+12% dari bulan lalu</span>
            </div>
          </div>
          <div class="stat-icon bg-blue">
            <i class="bi bi-bag-check"></i>
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-content">
          <div class="stat-info">
            <p class="stat-label">Pending</p>
            <h2 class="stat-value">{{ stats.pending }}</h2>
            <div class="stat-change">
              <span>Menunggu proses</span>
            </div>
          </div>
          <div class="stat-icon bg-warning">
            <i class="bi bi-clock-history"></i>
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-content">
          <div class="stat-info">
            <p class="stat-label">Processing</p>
            <h2 class="stat-value">{{ stats.processing }}</h2>
            <div class="stat-change">
              <span>Sedang diproses</span>
            </div>
          </div>
          <div class="stat-icon bg-info">
            <i class="bi bi-arrow-repeat"></i>
          </div>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-content">
          <div class="stat-info">
            <p class="stat-label">Delivered</p>
            <h2 class="stat-value">{{ stats.delivered }}</h2>
            <div class="stat-change positive">
              <i class="bi bi-arrow-up"></i>
              <span>+8% minggu ini</span>
            </div>
          </div>
          <div class="stat-icon bg-success">
            <i class="bi bi-check-circle"></i>
          </div>
        </div>
      </div>
    </div>

    <!-- Filters & Search -->
    <div class="content-card">
      <div class="filter-section">
        <div class="filter-left">
          <div class="btn-group" role="group">
            <button
              v-for="status in statusFilters"
              :key="status.value"
              @click="filterStatus = status.value"
              class="filter-btn"
              :class="{ active: filterStatus === status.value }"
            >
              {{ status.label }}
              <span class="count">({{ getStatusCount(status.value) }})</span>
            </button>
          </div>
        </div>
        <div class="filter-right">
          <div class="search-box">
            <i class="bi bi-search"></i>
            <input
              type="text"
              v-model="searchQuery"
              placeholder="Cari order ID, customer, email..."
            />
          </div>
        </div>
      </div>

      <!-- Orders Table -->
      <div class="table-container">
        <div v-if="loading" class="loading-state">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <p class="mt-3">Memuat data pesanan...</p>
        </div>

        <table v-else class="orders-table">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Customer</th>
              <th>Items</th>
              <th>Total</th>
              <th>Payment</th>
              <th>Status</th>
              <th>Tanggal</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="filteredOrders.length === 0">
              <td colspan="8" class="empty-state">
                <i class="bi bi-inbox"></i>
                <p>Tidak ada pesanan ditemukan</p>
              </td>
            </tr>
            <tr v-for="order in filteredOrders" :key="order.id" class="order-row">
              <td>
                <strong class="order-id">#{{ order.id }}</strong>
              </td>
              <td>
                <div class="customer-info">
                  <img :src="order.customer_avatar || 'https://i.pravatar.cc/40'"
                       alt="avatar" class="customer-avatar" />
                  <div>
                    <div class="customer-name">{{ order.customer_name }}</div>
                    <div class="customer-email">{{ order.customer_email }}</div>
                  </div>
                </div>
              </td>
              <td>
                <span class="items-count">{{ order.items_count }} items</span>
              </td>
              <td>
                <strong class="order-total">{{ formatRupiah(order.total_amount) }}</strong>
              </td>
              <td>
                <span class="badge" :class="getPaymentBadge(order.payment_status)">
                  {{ order.payment_status || 'Pending' }}
                </span>
              </td>
              <td>
                <select
                  class="status-select"
                  :value="order.status"
                  @change="updateStatus(order.id, $event.target.value)"
                  :class="getStatusClass(order.status)"
                >
                  <option value="pending">Pending</option>
                  <option value="processing">Processing</option>
                  <option value="shipped">Shipped</option>
                  <option value="delivered">Delivered</option>
                  <option value="cancelled">Cancelled</option>
                </select>
              </td>
              <td>
                <div class="date-info">
                  <div>{{ formatDate(order.created_at) }}</div>
                  <small>{{ formatTime(order.created_at) }}</small>
                </div>
              </td>
              <td>
                <div class="action-buttons">
                  <button
                    @click="viewOrder(order)"
                    class="action-btn view"
                    title="Lihat Detail"
                  >
                    <i class="bi bi-eye"></i>
                  </button>
                  <button
                    @click="printInvoice(order.id)"
                    class="action-btn print"
                    title="Print Invoice"
                  >
                    <i class="bi bi-printer"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Order Detail Modal -->
    <div v-if="selectedOrder" class="modal-overlay" @click="selectedOrder = null">
      <div class="modal-container" @click.stop>
        <div class="modal-header">
          <h3><i class="bi bi-receipt me-2"></i>Detail Pesanan #{{ selectedOrder.id }}</h3>
          <button class="modal-close" @click="selectedOrder = null">
            <i class="bi bi-x-lg"></i>
          </button>
        </div>

        <div class="modal-body">
          <div class="detail-grid">
            <!-- Customer Information -->
            <div class="detail-section">
              <h5 class="section-title">
                <i class="bi bi-person-circle me-2"></i>Informasi Customer
              </h5>
              <div class="detail-row">
                <span class="label">Nama:</span>
                <span class="value">{{ selectedOrder.customer_name }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Email:</span>
                <span class="value">{{ selectedOrder.customer_email }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Telepon:</span>
                <span class="value">{{ selectedOrder.shipping_phone }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Alamat:</span>
                <span class="value">{{ selectedOrder.shipping_address }}</span>
              </div>
            </div>

            <!-- Order Information -->
            <div class="detail-section">
              <h5 class="section-title">
                <i class="bi bi-bag-check me-2"></i>Informasi Pesanan
              </h5>
              <div class="detail-row">
                <span class="label">Order ID:</span>
                <span class="value">#{{ selectedOrder.id }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Status:</span>
                <span class="badge" :class="getStatusClass(selectedOrder.status)">
                  {{ selectedOrder.status }}
                </span>
              </div>
              <div class="detail-row">
                <span class="label">Total:</span>
                <span class="value text-success fw-bold">
                  {{ formatRupiah(selectedOrder.total_amount) }}
                </span>
              </div>
              <div class="detail-row">
                <span class="label">Tanggal:</span>
                <span class="value">{{ formatDate(selectedOrder.created_at) }}</span>
              </div>
            </div>
          </div>

          <!-- Order Items -->
          <div class="detail-section full-width">
            <h5 class="section-title">
              <i class="bi bi-box-seam me-2"></i>Item Pesanan
            </h5>
            <table class="items-table">
              <thead>
                <tr>
                  <th>Produk</th>
                  <th>Harga</th>
                  <th>Qty</th>
                  <th>Subtotal</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="item in selectedOrder.items" :key="item.id">
                  <td>{{ item.product_name }}</td>
                  <td>{{ formatRupiah(item.price) }}</td>
                  <td>{{ item.quantity }}</td>
                  <td>{{ formatRupiah(item.price * item.quantity) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr>
                  <td colspan="3" class="text-end fw-bold">Total:</td>
                  <td class="fw-bold text-success">
                    {{ formatRupiah(selectedOrder.total_amount) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-secondary" @click="selectedOrder = null">
            Tutup
          </button>
          <button class="btn btn-primary" @click="printInvoice(selectedOrder.id)">
            <i class="bi bi-printer me-2"></i>Print Invoice
          </button>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import AdminLayout from '../../components/admin/AdminLayout.vue'
import ordersApi from '../../api/orders'
import { formatRupiah } from '../../utils/currency'

export default {
  name: 'AdminOrders',
  components: {
    AdminLayout
  },
  setup() {
    const orders = ref([])
    const loading = ref(true)
    const selectedOrder = ref(null)
    const filterStatus = ref('')
    const searchQuery = ref('')

    const stats = computed(() => ({
      total: orders.value.length,
      pending: orders.value.filter(o => o.status === 'pending').length,
      processing: orders.value.filter(o => o.status === 'processing').length,
      delivered: orders.value.filter(o => o.status === 'delivered').length
    }))

    const statusFilters = [
      { value: '', label: 'Semua' },
      { value: 'pending', label: 'Pending' },
      { value: 'processing', label: 'Processing' },
      { value: 'shipped', label: 'Shipped' },
      { value: 'delivered', label: 'Delivered' },
      { value: 'cancelled', label: 'Cancelled' }
    ]

    const filteredOrders = computed(() => {
      let filtered = orders.value

      // Filter by status
      if (filterStatus.value) {
        filtered = filtered.filter(order => order.status === filterStatus.value)
      }

      // Filter by search query
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        filtered = filtered.filter(order =>
          order.id.toString().includes(query) ||
          order.customer_name.toLowerCase().includes(query) ||
          order.customer_email.toLowerCase().includes(query)
        )
      }

      return filtered
    })

    const getStatusCount = (status) => {
      if (!status) return orders.value.length
      return orders.value.filter(order => order.status === status).length
    }

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('id-ID', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const formatTime = (dateString) => {
      return new Date(dateString).toLocaleTimeString('id-ID', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const getStatusClass = (status) => {
      const classes = {
        pending: 'status-pending',
        processing: 'status-processing',
        shipped: 'status-shipped',
        delivered: 'status-delivered',
        cancelled: 'status-cancelled'
      }
      return classes[status] || 'status-pending'
    }

    const getPaymentBadge = (paymentStatus) => {
      const classes = {
        paid: 'badge-success',
        pending: 'badge-warning',
        failed: 'badge-danger'
      }
      return classes[paymentStatus] || 'badge-warning'
    }

    const viewOrder = (order) => {
      selectedOrder.value = order
    }

    const updateStatus = async (orderId, newStatus) => {
      if (!confirm(`Ubah status pesanan menjadi "${newStatus}"?`)) return

      try {
        await ordersApi.updateStatus(orderId, newStatus)
        alert('✅ Status pesanan berhasil diupdate!')
        fetchOrders()
      } catch (error) {
        alert('❌ Gagal update status pesanan')
      }
    }

    const printInvoice = (orderId) => {
      alert(`Mencetak invoice untuk pesanan #${orderId}`)
      // Implement print functionality
      window.print()
    }

    const fetchOrders = async () => {
      loading.value = true
      try {
        const response = await ordersApi.getAll()
        orders.value = response.data.data || []
      } catch (error) {
        console.error('Failed to fetch orders:', error)
        // Sample data for testing
        orders.value = [
          {
            id: 10,
            customer_name: 'John Doe',
            customer_email: 'john@example.com',
            customer_avatar: 'https://i.pravatar.cc/40?img=1',
            items_count: 1,
            total_amount: 15999000,
            payment_status: 'pending',
            status: 'pending',
            shipping_phone: '+6285880491365',
            shipping_address: 'Jl. Example No. 123, Jakarta',
            created_at: '2025-12-21 04:56:00',
            items: [
              {
                id: 1,
                product_name: 'Product Sample',
                price: 15999000,
                quantity: 1
              }
            ]
          },
          {
            id: 9,
            customer_name: 'Jane Smith',
            customer_email: 'jane@example.com',
            customer_avatar: 'https://i.pravatar.cc/40?img=2',
            items_count: 2,
            total_amount: 198000,
            payment_status: 'paid',
            status: 'processing',
            shipping_phone: '+6285880491365',
            shipping_address: 'Jl. Sample No. 456, Bandung',
            created_at: '2025-12-21 04:49:00',
            items: [
              {
                id: 1,
                product_name: 'Product A',
                price: 99000,
                quantity: 2
              }
            ]
          }
        ]
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
      selectedOrder,
      filterStatus,
      searchQuery,
      stats,
      statusFilters,
      filteredOrders,
      getStatusCount,
      formatDate,
      formatTime,
      getStatusClass,
      getPaymentBadge,
      viewOrder,
      updateStatus,
      printInvoice,
      fetchOrders,
      formatRupiah
    }
  }
}
</script>

<style scoped>
/* Page Header */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
  display: flex;
  align-items: center;
}

.page-subtitle {
  color: #6b7280;
  margin: 8px 0 0 0;
}

.header-actions {
  display: flex;
  gap: 12px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stat-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.stat-info {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
  margin: 0 0 8px 0;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 8px 0;
}

.stat-change {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #6b7280;
}

.stat-change.positive {
  color: #10b981;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
}

.stat-icon.bg-blue { background: #3b82f6; }
.stat-icon.bg-warning { background: #f59e0b; }
.stat-icon.bg-info { background: #06b6d4; }
.stat-icon.bg-success { background: #10b981; }

/* Content Card */
.content-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* Filter Section */
.filter-section {
  padding: 20px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.filter-left {
  flex: 1;
}

.btn-group {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-btn {
  padding: 8px 16px;
  border: 1px solid #e5e7eb;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
  color: #6b7280;
  display: flex;
  align-items: center;
  gap: 6px;
}

.filter-btn:hover {
  border-color: #3b82f6;
  color: #3b82f6;
}

.filter-btn.active {
  background: #3b82f6;
  border-color: #3b82f6;
  color: white;
}

.filter-btn .count {
  font-size: 12px;
  opacity: 0.8;
}

.search-box {
  display: flex;
  align-items: center;
  background: #f3f4f6;
  padding: 10px 16px;
  border-radius: 8px;
  width: 300px;
}

.search-box i {
  color: #6b7280;
  margin-right: 10px;
}

.search-box input {
  border: none;
  background: none;
  outline: none;
  width: 100%;
  font-size: 14px;
}

/* Table Container */
.table-container {
  overflow-x: auto;
}

.loading-state {
  text-align: center;
  padding: 60px 20px;
  color: #6b7280;
}

.orders-table {
  width: 100%;
  border-collapse: collapse;
}

.orders-table thead tr {
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}

.orders-table th {
  padding: 16px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.orders-table tbody tr {
  border-bottom: 1px solid #e5e7eb;
  transition: background 0.2s;
}

.orders-table tbody tr:hover {
  background: #f9fafb;
}

.orders-table td {
  padding: 16px;
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: #9ca3af;
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 12px;
  opacity: 0.5;
}

.empty-state p {
  margin: 0;
  font-size: 16px;
}

/* Table Content */
.order-id {
  color: #3b82f6;
  font-size: 14px;
}

.customer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.customer-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.customer-name {
  font-weight: 500;
  color: #1f2937;
  font-size: 14px;
}

.customer-email {
  font-size: 13px;
  color: #6b7280;
}

.items-count {
  color: #6b7280;
  font-size: 14px;
}

.order-total {
  color: #10b981;
  font-size: 15px;
}

.badge {
  padding: 4px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  display: inline-block;
}

.badge-success { background: #d1fae5; color: #065f46; }
.badge-warning { background: #fef3c7; color: #92400e; }
.badge-danger { background: #fee2e2; color: #991b1b; }

.status-select {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
}

.status-pending { background: #fef3c7; color: #92400e; }
.status-processing { background: #dbeafe; color: #1e40af; }
.status-shipped { background: #e0e7ff; color: #4338ca; }
.status-delivered { background: #d1fae5; color: #065f46; }
.status-cancelled { background: #fee2e2; color: #991b1b; }

.date-info {
  font-size: 14px;
}

.date-info small {
  color: #6b7280;
  font-size: 12px;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.action-btn.view {
  background: #dbeafe;
  color: #1e40af;
}

.action-btn.view:hover {
  background: #3b82f6;
  color: white;
}

.action-btn.print {
  background: #f3f4f6;
  color: #6b7280;
}

.action-btn.print:hover {
  background: #e5e7eb;
  color: #1f2937;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-container {
  background: white;
  border-radius: 16px;
  max-width: 900px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.modal-header {
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
}

.modal-close {
  width: 36px;
  height: 36px;
  border-radius: 8px;
  border: none;
  background: #f3f4f6;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.modal-close:hover {
  background: #e5e7eb;
}

.modal-body {
  padding: 24px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  margin-bottom: 24px;
}

.detail-section {
  background: #f9fafb;
  padding: 20px;
  border-radius: 12px;
}

.detail-section.full-width {
  grid-column: 1 / -1;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 16px 0;
  display: flex;
  align-items: center;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #e5e7eb;
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-row .label {
  font-weight: 500;
  color: #6b7280;
  font-size: 14px;
}

.detail-row .value {
  color: #1f2937;
  font-size: 14px;
  text-align: right;
}

.items-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
  border-radius: 8px;
  overflow: hidden;
}

.items-table thead {
  background: white;
}

.items-table th {
  padding: 12px;
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  border-bottom: 1px solid #e5e7eb;
}

.items-table td {
  padding: 12px;
  border-bottom: 1px solid #e5e7eb;
  font-size: 14px;
}

.items-table tfoot td {
  font-size: 16px;
  padding-top: 16px;
  border-bottom: none;
}

.modal-footer {
  padding: 20px 24px;
  border-top: 1px solid #e5e7eb;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

.btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: none;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
}

.btn-secondary {
  background: #f3f4f6;
  color: #6b7280;
}

.btn-secondary:hover {
  background: #e5e7eb;
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover {
  background: #2563eb;
}

.btn-outline-primary {
  background: white;
  border: 1px solid #3b82f6;
  color: #3b82f6;
}

.btn-outline-primary:hover {
  background: #3b82f6;
  color: white;
}

/* Responsive */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .filter-section {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box {
    width: 100%;
  }

  .detail-grid {
    grid-template-columns: 1fr;
  }

  .orders-table {
    font-size: 13px;
  }

  .customer-info {
    flex-direction: column;
    align-items: flex-start;
  }
}
</style>
