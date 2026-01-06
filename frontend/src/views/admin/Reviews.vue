<template>
  <AdminLayout>
    <div class="reviews-page">
      <!-- Header -->
      <div class="page-header">
        <div>
          <h1 class="page-title">Customer Reviews</h1>
          <p class="page-subtitle">Manage and respond to customer product reviews</p>
        </div>
        <div class="header-actions">
          <select v-model="ratingFilter" class="filter-select">
            <option value="all">All Ratings</option>
            <option value="5">5 Stars</option>
            <option value="4">4 Stars</option>
            <option value="3">3 Stars</option>
            <option value="2">2 Stars</option>
            <option value="1">1 Star</option>
          </select>
          <select v-model="statusFilter" class="filter-select">
            <option value="all">All Status</option>
            <option value="pending">Pending</option>
            <option value="approved">Approved</option>
            <option value="rejected">Rejected</option>
          </select>
        </div>
      </div>

      <!-- Stats -->
      <div class="stats-grid">
        <div class="stat-card">
          <i class="bi bi-star-fill"></i>
          <div>
            <h3>{{ stats.avgRating }}</h3>
            <p>Average Rating</p>
          </div>
        </div>
        <div class="stat-card">
          <i class="bi bi-chat-left-text"></i>
          <div>
            <h3>{{ stats.totalReviews }}</h3>
            <p>Total Reviews</p>
          </div>
        </div>
        <div class="stat-card">
          <i class="bi bi-clock-history"></i>
          <div>
            <h3>{{ stats.pending }}</h3>
            <p>Pending Approval</p>
          </div>
        </div>
        <div class="stat-card">
          <i class="bi bi-check-circle"></i>
          <div>
            <h3>{{ stats.approved }}</h3>
            <p>Approved</p>
          </div>
        </div>
      </div>

      <!-- Reviews List -->
      <div class="reviews-card">
        <div class="reviews-header">
          <h3>All Reviews</h3>
          <div class="search-box">
            <i class="bi bi-search"></i>
            <input type="text" placeholder="Search reviews..." v-model="searchQuery" />
          </div>
        </div>

        <div v-if="loading" class="loading-state">
          <div class="spinner-border text-primary"></div>
          <p>Loading reviews...</p>
        </div>

        <div v-else class="reviews-list">
          <div class="review-item" v-for="review in filteredReviews" :key="review.id">
            <div class="review-header-row">
              <div class="customer-info">
                <img :src="review.customerAvatar" :alt="review.customerName" class="avatar" />
                <div>
                  <h4 class="customer-name">{{ review.customerName }}</h4>
                  <p class="review-date">{{ formatDate(review.createdAt) }}</p>
                </div>
              </div>
              <div class="review-actions">
                <div class="rating">
                  <i v-for="n in 5" :key="n" class="bi" :class="n <= review.rating ? 'bi-star-fill' : 'bi-star'"></i>
                </div>
                <span class="status-badge" :class="'status-' + review.status">{{ review.status }}</span>
              </div>
            </div>

            <div class="product-info">
              <img :src="review.productImage" :alt="review.productName" class="product-image" />
              <span class="product-name">{{ review.productName }}</span>
            </div>

            <p class="review-text">{{ review.comment }}</p>

            <div v-if="review.images && review.images.length > 0" class="review-images">
              <img v-for="(img, idx) in review.images" :key="idx" :src="img" alt="Review image" />
            </div>

            <div class="review-footer">
              <button v-if="review.status === 'pending'" class="btn-approve" @click="approveReview(review)">
                <i class="bi bi-check-circle"></i>
                Approve
              </button>
              <button v-if="review.status === 'pending'" class="btn-reject" @click="rejectReview(review)">
                <i class="bi bi-x-circle"></i>
                Reject
              </button>
              <button class="btn-reply" @click="replyToReview(review)">
                <i class="bi bi-reply"></i>
                Reply
              </button>
              <button class="btn-delete" @click="deleteReview(review)">
                <i class="bi bi-trash"></i>
                Delete
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import AdminLayout from '../../components/admin/AdminLayout.vue'

export default {
  name: 'AdminReviews',
  components: {
    AdminLayout
  },
  setup() {
    const loading = ref(false)
    const ratingFilter = ref('all')
    const statusFilter = ref('all')
    const searchQuery = ref('')

    const stats = ref({
      avgRating: 4.5,
      totalReviews: 156,
      pending: 12,
      approved: 142,
      rejected: 2
    })

    const reviews = ref([
      {
        id: 1,
        customerName: 'John Doe',
        customerAvatar: 'https://i.pravatar.cc/50?img=1',
        productName: 'Wireless Earbuds Pro',
        productImage: 'https://via.placeholder.com/50',
        rating: 5,
        comment: 'Amazing product! Sound quality is excellent and battery life is great. Highly recommended!',
        images: ['https://via.placeholder.com/100'],
        status: 'pending',
        createdAt: '2025-12-20T10:30:00'
      },
      {
        id: 2,
        customerName: 'Jane Smith',
        customerAvatar: 'https://i.pravatar.cc/50?img=2',
        productName: 'Smart Watch X1',
        productImage: 'https://via.placeholder.com/50',
        rating: 4,
        comment: 'Good smartwatch with lots of features. Battery could be better though.',
        images: [],
        status: 'approved',
        createdAt: '2025-12-19T14:20:00'
      },
      {
        id: 3,
        customerName: 'Mike Johnson',
        customerAvatar: 'https://i.pravatar.cc/50?img=3',
        productName: 'Gaming Mouse RGB',
        productImage: 'https://via.placeholder.com/50',
        rating: 5,
        comment: 'Perfect for gaming! The RGB lighting is stunning and the buttons are very responsive.',
        images: ['https://via.placeholder.com/100', 'https://via.placeholder.com/100'],
        status: 'approved',
        createdAt: '2025-12-18T09:15:00'
      }
    ])

    const filteredReviews = computed(() => {
      let result = reviews.value

      if (ratingFilter.value !== 'all') {
        result = result.filter(r => r.rating === parseInt(ratingFilter.value))
      }

      if (statusFilter.value !== 'all') {
        result = result.filter(r => r.status === statusFilter.value)
      }

      if (searchQuery.value) {
        const query = searchQuery.value.toLowerCase()
        result = result.filter(r =>
          r.customerName.toLowerCase().includes(query) ||
          r.productName.toLowerCase().includes(query) ||
          r.comment.toLowerCase().includes(query)
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

    const approveReview = (review) => {
      if (confirm(`Approve review from ${review.customerName}?`)) {
        review.status = 'approved'
        stats.value.pending--
        stats.value.approved++
        alert('Review approved!')
      }
    }

    const rejectReview = (review) => {
      const reason = prompt('Enter rejection reason:')
      if (reason) {
        review.status = 'rejected'
        stats.value.pending--
        stats.value.rejected++
        alert('Review rejected!')
      }
    }

    const replyToReview = (review) => {
      const reply = prompt(`Reply to ${review.customerName}:`)
      if (reply) {
        alert('Reply sent!')
      }
    }

    const deleteReview = (review) => {
      if (confirm(`Delete review from ${review.customerName}?`)) {
        const index = reviews.value.indexOf(review)
        reviews.value.splice(index, 1)
        alert('Review deleted!')
      }
    }

    onMounted(() => {
      // TODO: Fetch reviews from API
    })

    return {
      loading,
      ratingFilter,
      statusFilter,
      searchQuery,
      stats,
      reviews,
      filteredReviews,
      formatDate,
      approveReview,
      rejectReview,
      replyToReview,
      deleteReview
    }
  }
}
</script>

<style scoped>
.reviews-page {
  max-width: 1400px;
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

.filter-select {
  padding: 10px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  background: #fff;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  background: #fff;
  padding: 24px;
  border-radius: 12px;
  border: 1px solid #e5e7eb;
}

.stat-card i {
  font-size: 32px;
  color: #f59e0b;
}

.stat-card h3 {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin: 0;
}

.stat-card p {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

.reviews-card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
}

.reviews-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid #e5e7eb;
}

.reviews-header h3 {
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

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #6b7280;
}

.reviews-list {
  padding: 24px;
}

.review-item {
  padding: 20px;
  background: #f9fafb;
  border-radius: 12px;
  margin-bottom: 16px;
}

.review-item:last-child {
  margin-bottom: 0;
}

.review-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.customer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  object-fit: cover;
}

.customer-name {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.review-date {
  font-size: 13px;
  color: #6b7280;
  margin: 0;
}

.review-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.rating {
  display: flex;
  gap: 4px;
  color: #f59e0b;
  font-size: 16px;
}

.status-badge {
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

.status-approved {
  background: #d1fae5;
  color: #065f46;
}

.status-rejected {
  background: #fee2e2;
  color: #991b1b;
}

.product-info {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding: 12px;
  background: #fff;
  border-radius: 8px;
}

.product-image {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  object-fit: cover;
}

.product-name {
  font-size: 14px;
  font-weight: 500;
  color: #1f2937;
}

.review-text {
  color: #1f2937;
  line-height: 1.6;
  margin-bottom: 12px;
}

.review-images {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.review-images img {
  width: 100px;
  height: 100px;
  border-radius: 8px;
  object-fit: cover;
  cursor: pointer;
}

.review-footer {
  display: flex;
  gap: 8px;
}

.review-footer button {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-approve {
  background: #d1fae5;
  color: #065f46;
}

.btn-approve:hover {
  background: #a7f3d0;
}

.btn-reject {
  background: #fee2e2;
  color: #991b1b;
}

.btn-reject:hover {
  background: #fecaca;
}

.btn-reply {
  background: #dbeafe;
  color: #1e40af;
}

.btn-reply:hover {
  background: #bfdbfe;
}

.btn-delete {
  background: #f3f4f6;
  color: #6b7280;
}

.btn-delete:hover {
  background: #e5e7eb;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
  }

  .header-actions {
    width: 100%;
  }

  .filter-select {
    flex: 1;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .search-box {
    width: 100%;
  }

  .review-header-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }

  .review-footer {
    flex-wrap: wrap;
  }
}
</style>
