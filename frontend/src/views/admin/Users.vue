<template>
  <div class="admin-users">
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
                <router-link to="/admin/users" class="nav-link active">
                  <i class="bi bi-people me-2"></i>Users
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/admin/orders" class="nav-link">
                  <i class="bi bi-bag me-2"></i>Orders
                </router-link>
              </li>
              <li class="nav-item">
                <router-link to="/admin/transactions" class="nav-link">
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
            <h1 class="h2"><i class="bi bi-people me-2"></i>User Management</h1>
            <div class="btn-toolbar mb-2 mb-md-0">
              <button class="btn btn-sm btn-primary me-2" @click="showAddUserModal">
                <i class="bi bi-plus-circle me-1"></i>Add User
              </button>
              <button class="btn btn-sm btn-outline-secondary" @click="loadUsers">
                <i class="bi bi-arrow-clockwise me-1"></i>Refresh
              </button>
            </div>
          </div>

          <!-- Statistics Cards -->
          <div class="row mb-4">
            <div class="col-md-3 mb-3">
              <div class="card bg-primary text-white h-100">
                <div class="card-body">
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="card-title">Total Users</h6>
                      <h3 class="mb-0">{{ stats.total_users || 0 }}</h3>
                    </div>
                    <i class="bi bi-people" style="font-size: 2.5rem; opacity: 0.3;"></i>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-3 mb-3">
              <div class="card bg-success text-white h-100">
                <div class="card-body">
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="card-title">Customers</h6>
                      <h3 class="mb-0">{{ stats.total_customers || 0 }}</h3>
                    </div>
                    <i class="bi bi-person-check" style="font-size: 2.5rem; opacity: 0.3;"></i>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-3 mb-3">
              <div class="card bg-info text-white h-100">
                <div class="card-body">
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="card-title">Active Users</h6>
                      <h3 class="mb-0">{{ stats.active_users || 0 }}</h3>
                    </div>
                    <i class="bi bi-person-check-fill" style="font-size: 2.5rem; opacity: 0.3;"></i>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-md-3 mb-3">
              <div class="card bg-warning text-dark h-100">
                <div class="card-body">
                  <div class="d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="card-title">New (30 days)</h6>
                      <h3 class="mb-0">{{ stats.recent_users || 0 }}</h3>
                    </div>
                    <i class="bi bi-person-plus" style="font-size: 2.5rem; opacity: 0.3;"></i>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Filters -->
          <div class="card mb-3">
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-4">
                  <input
                    v-model="filters.search"
                    @input="searchUsers"
                    type="text"
                    class="form-control"
                    placeholder="Search by name, email, or phone..."
                  >
                </div>
                <div class="col-md-3">
                  <select v-model="filters.role" @change="loadUsers" class="form-select">
                    <option value="">All Roles</option>
                    <option value="customer">Customer</option>
                    <option value="admin">Admin</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <select v-model="filters.perPage" @change="loadUsers" class="form-select">
                    <option :value="10">10 per page</option>
                    <option :value="25">25 per page</option>
                    <option :value="50">50 per page</option>
                    <option :value="100">100 per page</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button class="btn btn-outline-secondary w-100" @click="clearFilters">
                    <i class="bi bi-x-circle me-1"></i>Clear
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Users Table -->
          <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
              <h5 class="mb-0">All Users</h5>
              <span class="badge bg-secondary">{{ pagination.total || 0 }} total</span>
            </div>
            <div class="card-body p-0">
              <div v-if="loading" class="text-center py-5">
                <div class="spinner-border" role="status">
                  <span class="visually-hidden">Loading...</span>
                </div>
              </div>

              <div v-else-if="users.length === 0" class="text-center py-5 text-muted">
                <i class="bi bi-inbox" style="font-size: 3rem;"></i>
                <p class="mt-3">No users found</p>
              </div>

              <div v-else class="table-responsive">
                <table class="table table-hover mb-0">
                  <thead class="table-light">
                    <tr>
                      <th>ID</th>
                      <th>Name</th>
                      <th>Email</th>
                      <th>Phone</th>
                      <th>Role</th>
                      <th>Status</th>
                      <th>Joined</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="user in users" :key="user.id">
                      <td><strong>#{{ user.id }}</strong></td>
                      <td>
                        <div class="d-flex align-items-center">
                          <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-2"
                               style="width: 35px; height: 35px;">
                            {{ getInitials(user.name) }}
                          </div>
                          <div>
                            <div>{{ user.name }}</div>
                          </div>
                        </div>
                      </td>
                      <td>{{ user.email }}</td>
                      <td>{{ user.phone || '-' }}</td>
                      <td>
                        <span class="badge" :class="user.role === 'admin' ? 'bg-danger' : 'bg-primary'">
                          {{ user.role.toUpperCase() }}
                        </span>
                      </td>
                      <td>
                        <button
                          class="btn btn-sm"
                          :class="user.is_active ? 'btn-success' : 'btn-secondary'"
                          @click="toggleUserStatus(user)"
                        >
                          <i :class="user.is_active ? 'bi bi-check-circle' : 'bi bi-x-circle'"></i>
                          {{ user.is_active ? 'Active' : 'Inactive' }}
                        </button>
                      </td>
                      <td>{{ formatDate(user.created_at) }}</td>
                      <td>
                        <div class="btn-group btn-group-sm">
                          <button class="btn btn-outline-primary" @click="editUser(user)" title="Edit">
                            <i class="bi bi-pencil"></i>
                          </button>
                          <button class="btn btn-outline-danger" @click="confirmDeleteUser(user)" title="Delete">
                            <i class="bi bi-trash"></i>
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Pagination -->
            <div v-if="pagination.total_pages > 1" class="card-footer">
              <nav>
                <ul class="pagination mb-0 justify-content-center">
                  <li class="page-item" :class="{ disabled: pagination.current_page === 1 }">
                    <button class="page-link" @click="changePage(pagination.current_page - 1)">Previous</button>
                  </li>
                  <li
                    v-for="page in visiblePages"
                    :key="page"
                    class="page-item"
                    :class="{ active: page === pagination.current_page }"
                  >
                    <button class="page-link" @click="changePage(page)">{{ page }}</button>
                  </li>
                  <li class="page-item" :class="{ disabled: pagination.current_page === pagination.total_pages }">
                    <button class="page-link" @click="changePage(pagination.current_page + 1)">Next</button>
                  </li>
                </ul>
              </nav>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Add/Edit User Modal -->
    <div class="modal fade" :class="{ show: showModal }" :style="{ display: showModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ editingUser ? 'Edit User' : 'Add New User' }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveUser">
              <div class="mb-3">
                <label class="form-label">Name *</label>
                <input v-model="formData.name" type="text" class="form-control" required>
              </div>
              <div class="mb-3">
                <label class="form-label">Email *</label>
                <input v-model="formData.email" type="email" class="form-control" required>
              </div>
              <div class="mb-3">
                <label class="form-label">{{ editingUser ? 'Password (leave empty to keep current)' : 'Password *' }}</label>
                <input v-model="formData.password" type="password" class="form-control" :required="!editingUser">
              </div>
              <div class="mb-3">
                <label class="form-label">Phone</label>
                <input v-model="formData.phone" type="text" class="form-control">
              </div>
              <div class="mb-3">
                <label class="form-label">Address</label>
                <textarea v-model="formData.address" class="form-control" rows="2"></textarea>
              </div>
              <div class="mb-3">
                <label class="form-label">Role *</label>
                <select v-model="formData.role" class="form-select" required>
                  <option value="customer">Customer</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
              <div class="mb-3">
                <div class="form-check">
                  <input v-model="formData.is_active" class="form-check-input" type="checkbox" id="isActive">
                  <label class="form-check-label" for="isActive">
                    Active
                  </label>
                </div>
              </div>
              <div v-if="formError" class="alert alert-danger">{{ formError }}</div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancel</button>
            <button type="button" class="btn btn-primary" @click="saveUser" :disabled="saving">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              {{ editingUser ? 'Update' : 'Create' }}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="showModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import api from '../../api/axios'

export default {
  name: 'AdminUsers',
  setup() {
    const loading = ref(false)
    const saving = ref(false)
    const users = ref([])
    const stats = ref({})
    const showModal = ref(false)
    const editingUser = ref(null)
    const formError = ref('')

    const filters = ref({
      search: '',
      role: '',
      perPage: 10
    })

    const pagination = ref({
      current_page: 1,
      per_page: 10,
      total: 0,
      total_pages: 0
    })

    const formData = ref({
      name: '',
      email: '',
      password: '',
      phone: '',
      address: '',
      role: 'customer',
      is_active: true
    })

    let searchTimeout = null

    const visiblePages = computed(() => {
      const pages = []
      const total = pagination.value.total_pages
      const current = pagination.value.current_page

      if (total <= 7) {
        for (let i = 1; i <= total; i++) {
          pages.push(i)
        }
      } else {
        if (current <= 4) {
          for (let i = 1; i <= 5; i++) pages.push(i)
          pages.push('...')
          pages.push(total)
        } else if (current >= total - 3) {
          pages.push(1)
          pages.push('...')
          for (let i = total - 4; i <= total; i++) pages.push(i)
        } else {
          pages.push(1)
          pages.push('...')
          for (let i = current - 1; i <= current + 1; i++) pages.push(i)
          pages.push('...')
          pages.push(total)
        }
      }

      return pages
    })

    const loadUsers = async (page = 1) => {
      loading.value = true
      try {
        const params = {
          page,
          per_page: filters.value.perPage
        }

        if (filters.value.search) {
          params.search = filters.value.search
        }

        if (filters.value.role) {
          params.role = filters.value.role
        }

        const response = await api.get('/admin/users', { params })

        if (response.data.success) {
          users.value = response.data.data.users
          pagination.value = response.data.data.pagination
        }
      } catch (error) {
        console.error('Failed to load users:', error)
        alert('Failed to load users. Please try again.')
      } finally {
        loading.value = false
      }
    }

    const loadStats = async () => {
      try {
        const response = await api.get('/admin/users/stats')
        if (response.data.success) {
          stats.value = response.data.data.stats
        }
      } catch (error) {
        console.error('Failed to load stats:', error)
      }
    }

    const searchUsers = () => {
      clearTimeout(searchTimeout)
      searchTimeout = setTimeout(() => {
        loadUsers(1)
      }, 500)
    }

    const clearFilters = () => {
      filters.value.search = ''
      filters.value.role = ''
      filters.value.perPage = 10
      loadUsers(1)
    }

    const changePage = (page) => {
      if (page >= 1 && page <= pagination.value.total_pages) {
        loadUsers(page)
      }
    }

    const showAddUserModal = () => {
      editingUser.value = null
      formData.value = {
        name: '',
        email: '',
        password: '',
        phone: '',
        address: '',
        role: 'customer',
        is_active: true
      }
      formError.value = ''
      showModal.value = true
    }

    const editUser = (user) => {
      editingUser.value = user
      formData.value = {
        name: user.name,
        email: user.email,
        password: '',
        phone: user.phone || '',
        address: user.address || '',
        role: user.role,
        is_active: user.is_active == 1
      }
      formError.value = ''
      showModal.value = true
    }

    const closeModal = () => {
      showModal.value = false
      editingUser.value = null
      formError.value = ''
    }

    const saveUser = async () => {
      formError.value = ''
      saving.value = true

      try {
        const payload = {
          name: formData.value.name,
          email: formData.value.email,
          phone: formData.value.phone,
          address: formData.value.address,
          role: formData.value.role,
          is_active: formData.value.is_active ? 1 : 0
        }

        if (formData.value.password) {
          payload.password = formData.value.password
        }

        let response
        if (editingUser.value) {
          response = await api.put(`/admin/users/${editingUser.value.id}`, payload)
        } else {
          response = await api.post('/admin/users', payload)
        }

        if (response.data.success) {
          closeModal()
          loadUsers(pagination.value.current_page)
          loadStats()
          alert(response.data.message || 'User saved successfully')
        }
      } catch (error) {
        console.error('Failed to save user:', error)
        formError.value = error.response?.data?.message || 'Failed to save user. Please try again.'
      } finally {
        saving.value = false
      }
    }

    const toggleUserStatus = async (user) => {
      if (!confirm(`Are you sure you want to ${user.is_active ? 'deactivate' : 'activate'} this user?`)) {
        return
      }

      try {
        const response = await api.put(`/admin/users/${user.id}/toggle-status`)

        if (response.data.success) {
          loadUsers(pagination.value.current_page)
          loadStats()
          alert(response.data.message || 'User status updated successfully')
        }
      } catch (error) {
        console.error('Failed to toggle user status:', error)
        alert(error.response?.data?.message || 'Failed to update user status. Please try again.')
      }
    }

    const confirmDeleteUser = async (user) => {
      if (!confirm(`Are you sure you want to delete user "${user.name}"? This action cannot be undone.`)) {
        return
      }

      try {
        const response = await api.delete(`/admin/users/${user.id}`)

        if (response.data.success) {
          loadUsers(pagination.value.current_page)
          loadStats()
          alert(response.data.message || 'User deleted successfully')
        }
      } catch (error) {
        console.error('Failed to delete user:', error)
        alert(error.response?.data?.message || 'Failed to delete user. Please try again.')
      }
    }

    const formatDate = (dateString) => {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    }

    const getInitials = (name) => {
      return name
        .split(' ')
        .map(word => word[0])
        .join('')
        .toUpperCase()
        .substring(0, 2)
    }

    onMounted(() => {
      loadUsers()
      loadStats()
    })

    return {
      loading,
      saving,
      users,
      stats,
      filters,
      pagination,
      showModal,
      editingUser,
      formData,
      formError,
      visiblePages,
      loadUsers,
      searchUsers,
      clearFilters,
      changePage,
      showAddUserModal,
      editUser,
      closeModal,
      saveUser,
      toggleUserStatus,
      confirmDeleteUser,
      formatDate,
      getInitials
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
  background-color: rgba(0, 0, 0, 0.5);
}

.modal-backdrop {
  z-index: 1040;
}

.modal {
  z-index: 1050;
}
</style>
