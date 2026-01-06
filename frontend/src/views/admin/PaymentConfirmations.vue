<template>
  <AdminLayout>
    <div class="payment-confirmations">
      <!-- Header -->
      <div class="page-header">
        <div>
          <h1 class="page-title">Payment Confirmations</h1>
          <p class="page-subtitle">Manage customer payment confirmations and verify transactions</p>
        </div>
        <div class="header-actions">
          <select v-model="statusFilter" class="status-filter">
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="verified">Verified</option>
            <option value="rejected">Rejected</option>
          </select>
          <button class="refresh-btn" @click="fetchConfirmations">
            <i class="bi bi-arrow-clockwise"></i>
            Refresh
          </button>
        </div>
      </div>

      <!-- Stats Cards -->
      <div class="stats-row">
        <div class="stat-card stat-pending">
          <div class="stat-icon">
            <i class="bi bi-clock-history"></i>
          </div>
          <div class="stat-info">
            <h3>{{ stats.pending }}</h3>
            <p>Pending Confirmation</p>
          </div>
        </div>
        <div class="stat-card stat-verified">
          <div class="stat-icon">
            <i class="bi bi-check-circle"></i>
          </div>
          <div class="stat-info">
            <h3>{{ stats.verified }}</h3>
            <p>Verified Today</p>
          </div>
        </div>
        <div class="stat-card stat-rejected">
          <div class="stat-icon">
            <i class="bi bi-x-circle"></i>
          </div>
          <div class="stat-info">
            <h3>{{ stats.rejected }}</h3>
            <p>Rejected</p>
          </div>
        </div>
        <div class="stat-card stat-total">
          <div class="stat-icon">
            <i class="bi bi-cash-stack"></i>
          </div>
          <div class="stat-info">
            <h3>${{ stats.totalAmount.toLocaleString() }}</h3>
            <p>Total Amount Pending</p>
          </div>
        </div>
      </div>

      <!-- Confirmations Table -->
      <div class="table-card">
        <div class="table-header">
          <h3>Payment Confirmations</h3>
          <div class="search-box">
            <i class="bi bi-search"></i>
            <input
              type="text"
              placeholder="Search by order ID, customer name..."
              v-model="searchQuery"
            />
          </div>
        </div>

        <div v-if="loading" class="loading-state">
          <div class="spinner-border text-primary"></div>
          <p>Loading confirmations...</p>
        </div>

        <div v-else-if="filteredConfirmations.length === 0" class="empty-state">
          <i class="bi bi-inbox"></i>
          <h3>No confirmations found</h3>
          <p>There are no payment confirmations matching your criteria</p>
        </div>

        <div v-else class="table-responsive">
          <table class="confirmations-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Amount</th>
                <th>Payment Method</th>
                <th>Bank Account</th>
                <th>Payment Date</th>
                <th>Submitted</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="confirmation in filteredConfirmations" :key="confirmation.id">
                <td class="order-id">#{{ confirmation.order_id }}</td>
                <td>
                  <div class="customer-cell">
                    <img :src="confirmation.customer_avatar" :alt="confirmation.customer_name" />
                    <div>
                      <div class="customer-name">{{ confirmation.customer_name }}</div>
                      <div class="customer-email">{{ confirmation.customer_email }}</div>
                    </div>
                  </div>
                </td>
                <td class="amount">${{ confirmation.amount.toLocaleString() }}</td>
                <td>
                  <div class="payment-method">
                    <i class="bi bi-bank"></i>
                    {{ confirmation.payment_method }}
                  </div>
                </td>
                <td>
                  <div class="bank-info">
                    <div>{{ confirmation.bank_name }}</div>
                    <div class="account-number">{{ confirmation.account_number }}</div>
                  </div>
                </td>
                <td>{{ formatDate(confirmation.payment_date) }}</td>
                <td>{{ formatTimeAgo(confirmation.submitted_at) }}</td>
                <td>
                  <span class="status-badge" :class="'status-' + confirmation.status">
                    {{ confirmation.status }}
                  </span>
                </td>
                <td>
                  <div class="action-buttons">
                    <button
                      class="btn-view"
                      @click="viewDetails(confirmation)"
                      title="View Details"
                    >
                      <i class="bi bi-eye"></i>
                    </button>
                    <button
                      v-if="confirmation.status === 'pending'"
                      class="btn-verify"
                      @click="verifyPayment(confirmation)"
                      title="Verify Payment"
                    >
                      <i class="bi bi-check-circle"></i>
                    </button>
                    <button
                      v-if="confirmation.status === 'pending'"
                      class="btn-reject"
                      @click="rejectPayment(confirmation)"
                      title="Reject Payment"
                    >
                      <i class="bi bi-x-circle"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Detail Modal -->
      <div v-if="showModal" class="modal-overlay" @click="closeModal">
        <div class="modal-content" @click.stop>
          <div class="modal-header">
            <h3>Payment Confirmation Details</h3>
            <button class="close-btn" @click="closeModal">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>

          <div class="modal-body" v-if="selectedConfirmation">
            <div class="detail-section">
              <h4>Order Information</h4>
              <div class="detail-row">
                <span class="label">Order ID:</span>
                <span class="value">#{{ selectedConfirmation.order_id }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Customer:</span>
                <span class="value">{{ selectedConfirmation.customer_name }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Email:</span>
                <span class="value">{{ selectedConfirmation.customer_email }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Amount:</span>
                <span class="value amount-value">${{ selectedConfirmation.amount.toLocaleString() }}</span>
              </div>
            </div>

            <div class="detail-section">
              <h4>Payment Information</h4>
              <div class="detail-row">
                <span class="label">Payment Method:</span>
                <span class="value">{{ selectedConfirmation.payment_method }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Bank Name:</span>
                <span class="value">{{ selectedConfirmation.bank_name }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Account Number:</span>
                <span class="value">{{ selectedConfirmation.account_number }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Account Holder:</span>
                <span class="value">{{ selectedConfirmation.account_holder }}</span>
              </div>
              <div class="detail-row">
                <span class="label">Payment Date:</span>
                <span class="value">{{ formatDate(selectedConfirmation.payment_date) }}</span>
              </div>
            </div>

            <div class="detail-section" v-if="selectedConfirmation.proof_image">
              <h4>Payment Proof</h4>
              <img :src="selectedConfirmation.proof_image" alt="Payment Proof" class="proof-image" />
            </div>

            <div class="detail-section" v-if="selectedConfirmation.notes">
              <h4>Customer Notes</h4>
              <p class="notes">{{ selectedConfirmation.notes }}</p>
            </div>
          </div>

          <div class="modal-footer" v-if="selectedConfirmation?.status === 'pending'">
            <button class="btn btn-reject-modal" @click="rejectPayment(selectedConfirmation)">
              <i class="bi bi-x-circle"></i>
              Reject
            </button>
            <button class="btn btn-verify-modal" @click="verifyPayment(selectedConfirmation)">
              <i class="bi bi-check-circle"></i>
              Verify Payment
            </button>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import AdminLayout from '../../components/admin/AdminLayout.vue'
import paymentConfirmationsApi from '../../api/paymentConfirmations'

export default {
  name: 'PaymentConfirmations',
  components: {
    AdminLayout
  },
  setup() {
    const loading = ref(false)
    const statusFilter = ref('all')
    const searchQuery = ref('')
    const showModal = ref(false)
    const selectedConfirmation = ref(null)

    const stats = ref({
      pending: 12,
      verified: 45,
      rejected: 3,
      totalAmount: 15430
    })

    const confirmations = ref([
      {
        id: 1,
        order_id: '8441573',
        customer_name: 'Peterson Jack',
        customer_email: 'peterson@example.com',
        customer_avatar: 'https://i.pravatar.cc/40?img=1',
        amount: 2500,
        payment_method: 'Bank Transfer',
        bank_name: 'BCA',
        account_number: '1234567890',
        account_holder: 'Peterson Jack',
        payment_date: '2025-12-21',
        submitted_at: '2025-12-21 10:30:00',
        status: 'pending',
        proof_image: 'https://via.placeholder.com/600x400?text=Payment+Proof',
        notes: 'Pembayaran untuk order #8441573'
      },
      {
        id: 2,
        order_id: '2457841',
        customer_name: 'Michal Datta',
        customer_email: 'michal@example.com',
        customer_avatar: 'https://i.pravatar.cc/40?img=2',
        amount: 5400,
        payment_method: 'Bank Transfer',
        bank_name: 'Mandiri',
        account_number: '0987654321',
        account_holder: 'Michal Datta',
        payment_date: '2025-12-21',
        submitted_at: '2025-12-21 09:15:00',
        status: 'pending',
        proof_image: 'https://via.placeholder.com/600x400?text=Payment+Proof',
        notes: 'Transfer via mobile banking'
      },
      {
        id: 3,
        order_id: '1024784',
        customer_name: 'Jesiya Rose',
        customer_email: 'jesiya@example.com',
        customer_avatar: 'https://i.pravatar.cc/40?img=3',
        amount: 1200,
        payment_method: 'Bank Transfer',
        bank_name: 'BNI',
        account_number: '5555666677',
        account_holder: 'Jesiya Rose',
        payment_date: '2025-12-20',
        submitted_at: '2025-12-20 14:20:00',
        status: 'verified',
        proof_image: 'https://via.placeholder.com/600x400?text=Payment+Proof',
        notes: null
      }
    ])

    const filteredConfirmations = computed(() => {
      let result = confirmations.value

      // Filter by status
      if (statusFilter.value !== 'all') {
        result = result.filter(c => c.status === statusFilter.value)
      }

      // Filter by search query
      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        result = result.filter(c =>
          c.order_id.includes(query) ||
          c.customer_name.toLowerCase().includes(query) ||
          c.customer_email.toLowerCase().includes(query)
        )
      }

      return result
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

    const formatTimeAgo = (dateString) => {
      const date = new Date(dateString)
      const now = new Date()
      const diff = now - date
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const days = Math.floor(hours / 24)

      if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`
      if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''} ago`
      return 'Just now'
    }

    const fetchConfirmations = async () => {
      loading.value = true
      try {
        const { data } = await paymentConfirmationsApi.getAll()
        confirmations.value = data.data || []

        // Update stats
        stats.value.pending = confirmations.value.filter(c => c.status === 'pending').length
        stats.value.verified = confirmations.value.filter(c => c.status === 'verified').length
        stats.value.rejected = confirmations.value.filter(c => c.status === 'rejected').length
        stats.value.totalAmount = confirmations.value
          .filter(c => c.status === 'pending')
          .reduce((sum, c) => sum + parseFloat(c.amount || 0), 0)
      } catch (error) {
        console.error('Failed to fetch confirmations:', error)
        // Keep sample data if API fails
      } finally {
        loading.value = false
      }
    }

    const viewDetails = (confirmation) => {
      selectedConfirmation.value = confirmation
      showModal.value = true
    }

    const closeModal = () => {
      showModal.value = false
      selectedConfirmation.value = null
    }

    const verifyPayment = async (confirmation) => {
      if (!confirm(`Verify payment for order #${confirmation.order_id}?`)) return

      try {
        await paymentConfirmationsApi.verify(confirmation.id, {
          verified_at: new Date().toISOString()
        })

        alert('✅ Payment verified successfully!')
        closeModal()
        fetchConfirmations() // Refresh data
      } catch (error) {
        console.error('Failed to verify payment:', error)
        alert('❌ Failed to verify payment: ' + (error.response?.data?.message || error.message))
      }
    }

    const rejectPayment = async (confirmation) => {
      const reason = prompt(`Reject payment for order #${confirmation.order_id}?\n\nEnter rejection reason:`)
      if (!reason) return

      try {
        await paymentConfirmationsApi.reject(confirmation.id, {
          reason: reason,
          rejected_at: new Date().toISOString()
        })

        alert('✅ Payment rejected!')
        closeModal()
        fetchConfirmations() // Refresh data
      } catch (error) {
        console.error('Failed to reject payment:', error)
        alert('❌ Failed to reject payment: ' + (error.response?.data?.message || error.message))
      }
    }

    onMounted(() => {
      fetchConfirmations()
    })

    return {
      loading,
      statusFilter,
      searchQuery,
      showModal,
      selectedConfirmation,
      stats,
      confirmations,
      filteredConfirmations,
      formatDate,
      formatTimeAgo,
      fetchConfirmations,
      viewDetails,
      closeModal,
      verifyPayment,
      rejectPayment
    }
  }
}
</script>

<style scoped>
.payment-confirmations {
  max-width: 1600px;
}

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
  margin-bottom: 4px;
}

.page-subtitle {
  font-size: 14px;
  color: #6b7280;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.status-filter {
  padding: 10px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  background: #fff;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: #3b82f6;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.refresh-btn:hover {
  background: #2563eb;
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: #fff;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
  border: 1px solid #e5e7eb;
  transition: all 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  font-size: 24px;
}

.stat-pending .stat-icon {
  background: #fef3c7;
  color: #f59e0b;
}

.stat-verified .stat-icon {
  background: #d1fae5;
  color: #10b981;
}

.stat-rejected .stat-icon {
  background: #fee2e2;
  color: #ef4444;
}

.stat-total .stat-icon {
  background: #dbeafe;
  color: #3b82f6;
}

.stat-info h3 {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.stat-info p {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

.table-card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
}

.table-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.search-box {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  background: #f9fafb;
  border-radius: 8px;
  width: 300px;
}

.search-box i {
  color: #6b7280;
}

.search-box input {
  border: none;
  background: none;
  outline: none;
  width: 100%;
  font-size: 14px;
}

.loading-state,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #6b7280;
}

.empty-state i {
  font-size: 48px;
  margin-bottom: 16px;
  color: #d1d5db;
}

.empty-state h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 8px;
}

.table-responsive {
  overflow-x: auto;
}

.confirmations-table {
  width: 100%;
  border-collapse: collapse;
}

.confirmations-table th {
  text-align: left;
  padding: 16px 24px;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
  white-space: nowrap;
}

.confirmations-table td {
  padding: 16px 24px;
  font-size: 14px;
  color: #1f2937;
  border-bottom: 1px solid #f3f4f6;
}

.order-id {
  font-weight: 600;
  color: #3b82f6;
}

.customer-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.customer-cell img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.customer-name {
  font-weight: 600;
  color: #1f2937;
}

.customer-email {
  font-size: 12px;
  color: #6b7280;
}

.amount {
  font-weight: 600;
  color: #10b981;
}

.payment-method {
  display: flex;
  align-items: center;
  gap: 8px;
}

.bank-info div:first-child {
  font-weight: 500;
}

.account-number {
  font-size: 12px;
  color: #6b7280;
  font-family: monospace;
}

.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.status-verified {
  background: #d1fae5;
  color: #065f46;
}

.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.action-buttons button {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-view {
  background: #eff6ff;
  color: #3b82f6;
}

.btn-view:hover {
  background: #dbeafe;
}

.btn-verify {
  background: #d1fae5;
  color: #10b981;
}

.btn-verify:hover {
  background: #a7f3d0;
}

.btn-reject {
  background: #fee2e2;
  color: #ef4444;
}

.btn-reject:hover {
  background: #fecaca;
}

/* Modal Styles */
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
  z-index: 9999;
  padding: 20px;
}

.modal-content {
  background: #fff;
  border-radius: 16px;
  max-width: 700px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
}

.modal-header h3 {
  font-size: 20px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.close-btn {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f3f4f6;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e5e7eb;
}

.modal-body {
  padding: 24px;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.detail-section h4 {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 16px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 12px 0;
  border-bottom: 1px solid #f3f4f6;
}

.detail-row:last-child {
  border-bottom: none;
}

.detail-row .label {
  font-weight: 500;
  color: #6b7280;
}

.detail-row .value {
  font-weight: 600;
  color: #1f2937;
  text-align: right;
}

.amount-value {
  color: #10b981;
  font-size: 18px;
}

.proof-image {
  width: 100%;
  max-height: 400px;
  object-fit: contain;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
}

.notes {
  padding: 16px;
  background: #f9fafb;
  border-radius: 8px;
  color: #1f2937;
  line-height: 1.6;
  margin: 0;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 24px;
  border-top: 1px solid #e5e7eb;
}

.modal-footer .btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-reject-modal {
  background: #fee2e2;
  color: #991b1b;
}

.btn-reject-modal:hover {
  background: #fecaca;
}

.btn-verify-modal {
  background: #10b981;
  color: #fff;
}

.btn-verify-modal:hover {
  background: #059669;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
  }

  .header-actions {
    width: 100%;
  }

  .status-filter,
  .refresh-btn {
    flex: 1;
  }

  .stats-row {
    grid-template-columns: 1fr;
  }

  .search-box {
    width: 100%;
  }

  .confirmations-table {
    font-size: 12px;
  }

  .confirmations-table th,
  .confirmations-table td {
    padding: 12px 16px;
  }
}
</style>
