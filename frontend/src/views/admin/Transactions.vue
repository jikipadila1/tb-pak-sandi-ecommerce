<template>
  <div class="admin-transactions">
    <div class="container-fluid mt-4">
      <div class="row">
        <!-- Sidebar -->
        <div class="col-md-2 bg-light sidebar">
          <div class="position-sticky pt-3">
            <h5 class="px-3 mb-3">Admin Panel</h5>
            <ul class="nav flex-column">
              <li class="nav-item">
                <router-link to="/admin" class="nav-link">
                  <i class="bi bi-speedometer2 me-2"></i>Dashboard
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/admin/users" class="nav-link">
                  <i class="bi bi-people me-2"></i>Users
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/admin/orders" class="nav-link">
                  <i class="bi bi-bag me-2"></i>Orders
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/admin/transactions" class="nav-link active">
                  <i class="bi bi-credit-card me-2"></i>Transactions
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/" class="nav-link">
                  <i class="bi bi-house me-2"></i>Back to Site
                </router-link>
              </li>
            </ul>
          </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-10 ms-sm-auto px-md-4">
          <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
            <h1 class="h2"><i class="bi bi-credit-card me-2"></i>Transaction Management</h1>
            <div class="btn-toolbar mb-2 mb-md-0">
              <button class="btn btn-sm btn-outline-secondary" @click="fetchTransactions">
                <i class="bi bi-arrow-clockwise me-1"></i>Refresh
              </button>
            </div>
          </div>

          <!-- Statistics Cards -->
          <div class="row mb-4">
            <div class="col-md-3">
              <div class="card bg-primary text-white">
                <div class="card-body">
                  <h6 class="card-title">Total Transactions</h6>
                  <h3 class="mb-0">{{ stats.total }}</h3>
                </div>
              </div>
            </div>
            <div class="col-md-3">
              <div class="card bg-success text-white">
                <div class="card-body">
                  <h6 class="card-title">Successful</h6>
                  <h3 class="mb-0">{{ stats.successful }}</h3>
                  <small>${{ stats.successfulAmount }}</small>
                </div>
              </div>
            </div>
            <div class="col-md-3">
              <div class="card bg-warning text-white">
                <div class="card-body">
                  <h6 class="card-title">Pending</h6>
                  <h3 class="mb-0">{{ stats.pending }}</h3>
                  <small>${{ stats.pendingAmount }}</small>
                </div>
              </div>
            </div>
            <div class="col-md-3">
              <div class="card bg-danger text-white">
                <div class="card-body">
                  <h6 class="card-title">Failed</h6>
                  <h3 class="mb-0">{{ stats.failed }}</h3>
                </div>
              </div>
            </div>
          </div>

          <!-- Filters -->
          <div class="card mb-4">
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-3">
                  <label class="form-label small">Payment Method</label>
                  <select v-model="filters.payment_method" class="form-select form-select-sm" @change="applyFilters">
                    <option value="">All Methods</option>
                    <option value="credit_card">Credit Card</option>
                    <option value="bank_transfer">Bank Transfer</option>
                    <option value="e_wallet">E-Wallet</option>
                    <option value="cod">Cash on Delivery</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="form-label small">Status</label>
                  <select v-model="filters.status" class="form-select form-select-sm" @change="applyFilters">
                    <option value="">All Status</option>
                    <option value="pending">Pending</option>
                    <option value="processing">Processing</option>
                    <option value="success">Success</option>
                    <option value="failed">Failed</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="form-label small">Date From</label>
                  <input type="date" v-model="filters.date_from" class="form-control form-control-sm" @change="applyFilters" />
                </div>
                <div class="col-md-3">
                  <label class="form-label small">Date To</label>
                  <input type="date" v-model="filters.date_to" class="form-control form-control-sm" @change="applyFilters" />
                </div>
              </div>
            </div>
          </div>

          <!-- Transactions Table -->
          <div class="card">
            <div class="card-header">
              <h5 class="mb-0">All Transactions</h5>
            </div>
            <div class="card-body p-0">
              <div v-if="loading" class="text-center py-5">
                <div class="spinner-border" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
              </div>

              <div v-else class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>ID</th>
                      <th>Order ID</th>
                      <th>Customer</th>
                      <th>Amount</th>
                      <th>Payment Method</th>
                      <th>Status</th>
                      <th>Date</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="transactions.length === 0">
                      <td colspan="8" class="text-center py-4 text-muted">
                        No transactions found
                      </td>
                    </tr>
                    <tr v-for="transaction in transactions" :key="transaction.id">
                      <td><strong>#{{ transaction.id }}</strong></td>
                      <td>
                        <router-link :to="`/admin/orders/${transaction.order_id}`" class="text-decoration-none">
                          Order #{{ transaction.order_id }}
                        </router-link>
                      </td>
                      <td>
                        <div>{{ transaction.user_name }}</div>
                        <small class="text-muted">{{ transaction.user_email }}</small>
                      </td>
                      <td>
                        <strong class="text-success">${{ parseFloat(transaction.amount).toFixed(2) }}</strong>
                      </td>
                      <td>
                        <span class="badge bg-secondary">
                          {{ formatPaymentMethod(transaction.payment_method) }}
                        </span>
                      </td>
                      <td>
                        <span class="badge" :class="getStatusClass(transaction.status)">
                          {{ transaction.status.toUpperCase() }}
                        </span>
                      </td>
                      <td>
                        <div>{{ formatDate(transaction.created_at) }}</div>
                        <small class="text-muted">{{ formatTime(transaction.created_at) }}</small>
                      </td>
                      <td>
                        <div class="btn-group btn-group-sm">
                          <button
                            @click="viewTransaction(transaction)"
                            class="btn btn-outline-primary"
                            title="View Details"
                          >
                            <i class="bi bi-eye"></i>
                          </button>
                          <button
                            v-if="transaction.status === 'pending'"
                            @click="approveTransaction(transaction.id)"
                            class="btn btn-outline-success"
                            title="Approve"
                          >
                            <i class="bi bi-check-circle"></i>
                          </button>
                          <button
                            v-if="transaction.status === 'pending'"
                            @click="rejectTransaction(transaction.id)"
                            class="btn btn-outline-danger"
                            title="Reject"
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
          </div>

          <!-- Pagination -->
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

    <!-- Transaction Detail Modal -->
    <div v-if="selectedTransaction" class="modal fade show d-block" style="background: rgba(0,0,0,0.5);">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Transaction Details #{{ selectedTransaction.id }}</h5>
            <button type="button" class="btn-close" @click="selectedTransaction = null"></button>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-6">
                <h6 class="text-muted">Transaction Information</h6>
                <table class="table table-sm">
                  <tr>
                    <td><strong>Transaction ID:</strong></td>
                    <td>#{{ selectedTransaction.id }}</td>
                  </tr>
                  <tr>
                    <td><strong>Order ID:</strong></td>
                    <td>#{{ selectedTransaction.order_id }}</td>
                  </tr>
                  <tr>
                    <td><strong>Amount:</strong></td>
                    <td><strong class="text-success">${{ selectedTransaction.amount }}</strong></td>
                  </tr>
                  <tr>
                    <td><strong>Payment Method:</strong></td>
                    <td>{{ formatPaymentMethod(selectedTransaction.payment_method) }}</td>
                  </tr>
                  <tr>
                    <td><strong>Status:</strong></td>
                    <td>
                      <span class="badge" :class="getStatusClass(selectedTransaction.status)">
                        {{ selectedTransaction.status.toUpperCase() }}
                      </span>
                    </td>
                  </tr>
                </table>
              </div>
              <div class="col-6">
                <h6 class="text-muted">Customer Information</h6>
                <table class="table table-sm">
                  <tr>
                    <td><strong>Name:</strong></td>
                    <td>{{ selectedTransaction.user_name }}</td>
                  </tr>
                  <tr>
                    <td><strong>Email:</strong></td>
                    <td>{{ selectedTransaction.user_email }}</td>
                  </tr>
                  <tr>
                    <td><strong>Transaction Date:</strong></td>
                    <td>{{ formatDate(selectedTransaction.created_at) }}</td>
                  </tr>
                </table>
              </div>
            </div>

            <div v-if="selectedTransaction.payment_proof" class="mt-3">
              <h6 class="text-muted">Payment Proof</h6>
              <img :src="selectedTransaction.payment_proof" class="img-fluid rounded" alt="Payment Proof" />
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="selectedTransaction = null">Close</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'

export default {
  name: 'AdminTransactions',
  setup() {
    const transactions = ref([])
    const loading = ref(true)
    const selectedTransaction = ref(null)
    const pagination = ref({ current_page: 1, total_pages: 1 })

    const filters = ref({
      payment_method: '',
      status: '',
      date_from: '',
      date_to: ''
    })

    const stats = computed(() => {
      return {
        total: transactions.value.length,
        successful: transactions.value.filter(t => t.status === 'success').length,
        pending: transactions.value.filter(t => t.status === 'pending').length,
        failed: transactions.value.filter(t => t.status === 'failed').length,
        successfulAmount: transactions.value
          .filter(t => t.status === 'success')
          .reduce((sum, t) => sum + parseFloat(t.amount), 0)
          .toFixed(2),
        pendingAmount: transactions.value
          .filter(t => t.status === 'pending')
          .reduce((sum, t) => sum + parseFloat(t.amount), 0)
          .toFixed(2)
      }
    })

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const formatTime = (dateString) => {
      return new Date(dateString).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const formatPaymentMethod = (method) => {
      const methods = {
        credit_card: 'Credit Card',
        bank_transfer: 'Bank Transfer',
        e_wallet: 'E-Wallet',
        cod: 'Cash on Delivery'
      }
      return methods[method] || method
    }

    const getStatusClass = (status) => {
      const classes = {
        pending: 'bg-warning text-dark',
        processing: 'bg-info',
        success: 'bg-success',
        failed: 'bg-danger'
      }
      return classes[status] || 'bg-secondary'
    }

    const viewTransaction = (transaction) => {
      selectedTransaction.value = transaction
    }

    const approveTransaction = async (id) => {
      if (!confirm('Are you sure you want to approve this transaction?')) return

      try {
        // Call API to approve transaction
        alert('Transaction approved successfully')
        fetchTransactions()
      } catch (error) {
        alert('Failed to approve transaction')
      }
    }

    const rejectTransaction = async (id) => {
      if (!confirm('Are you sure you want to reject this transaction?')) return

      try {
        // Call API to reject transaction
        alert('Transaction rejected successfully')
        fetchTransactions()
      } catch (error) {
        alert('Failed to reject transaction')
      }
    }

    const applyFilters = () => {
      fetchTransactions()
    }

    const changePage = (page) => {
      if (page >= 1 && page <= pagination.value.total_pages) {
        fetchTransactions(page)
      }
    }

    const fetchTransactions = async (page = 1) => {
      loading.value = true
      try {
        // Mock data for demonstration
        transactions.value = [
          {
            id: 1,
            order_id: 1,
            user_name: 'John Doe',
            user_email: 'john@example.com',
            amount: '150.00',
            payment_method: 'credit_card',
            status: 'success',
            created_at: new Date().toISOString()
          },
          {
            id: 2,
            order_id: 2,
            user_name: 'Jane Smith',
            user_email: 'jane@example.com',
            amount: '89.50',
            payment_method: 'bank_transfer',
            status: 'pending',
            created_at: new Date().toISOString()
          }
        ]

        pagination.value = {
          current_page: page,
          total_pages: 1
        }
      } catch (error) {
        console.error('Failed to fetch transactions:', error)
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      fetchTransactions()
    })

    return {
      transactions,
      loading,
      selectedTransaction,
      pagination,
      filters,
      stats,
      formatDate,
      formatTime,
      formatPaymentMethod,
      getStatusClass,
      viewTransaction,
      approveTransaction,
      rejectTransaction,
      applyFilters,
      changePage,
      fetchTransactions
    }
  }
}
</script>

<style scoped>
.sidebar {
  min-height: 100vh;
}

.nav-link {
  color: #333;
}

.nav-link.active {
  background-color: #0d6efd;
  color: white;
}

.nav-link:hover {
  background-color: #e9ecef;
}

.modal.show {
  display: block;
}
</style>
