<template>
  <AdminLayout>
    <div class="sales-report">
      <!-- Header -->
      <div class="page-header">
        <div>
          <h1 class="page-title">Laporan Penjualan Bulanan</h1>
          <p class="page-subtitle">Analisis dan ringkasan penjualan per bulan</p>
        </div>
        <div class="header-actions">
          <select v-model="selectedYear" class="year-select" @change="loadReport">
            <option value="2025">2025</option>
            <option value="2024">2024</option>
            <option value="2023">2023</option>
          </select>
          <button class="export-btn" @click="exportToExcel">
            <i class="bi bi-file-earmark-excel"></i>
            Export Excel
          </button>
          <button class="export-btn btn-pdf" @click="exportToPDF">
            <i class="bi bi-file-earmark-pdf"></i>
            Export PDF
          </button>
        </div>
      </div>

      <!-- Summary Cards -->
      <div class="summary-grid">
        <div class="summary-card card-revenue">
          <div class="card-icon">
            <i class="bi bi-currency-dollar"></i>
          </div>
          <div class="card-content">
            <p class="card-label">Total Revenue {{ selectedYear }}</p>
            <h2 class="card-value">${{ summary.totalRevenue.toLocaleString() }}</h2>
            <div class="card-trend trend-up">
              <i class="bi bi-arrow-up"></i>
              <span>{{ summary.revenueGrowth }}% vs last year</span>
            </div>
          </div>
        </div>

        <div class="summary-card card-orders">
          <div class="card-icon">
            <i class="bi bi-bag-check"></i>
          </div>
          <div class="card-content">
            <p class="card-label">Total Orders</p>
            <h2 class="card-value">{{ summary.totalOrders.toLocaleString() }}</h2>
            <div class="card-trend trend-up">
              <i class="bi bi-arrow-up"></i>
              <span>{{ summary.ordersGrowth }}% vs last year</span>
            </div>
          </div>
        </div>

        <div class="summary-card card-average">
          <div class="card-icon">
            <i class="bi bi-graph-up"></i>
          </div>
          <div class="card-content">
            <p class="card-label">Average Order Value</p>
            <h2 class="card-value">${{ summary.avgOrderValue.toLocaleString() }}</h2>
            <div class="card-trend trend-down">
              <i class="bi bi-arrow-down"></i>
              <span>{{ summary.avgGrowth }}% vs last year</span>
            </div>
          </div>
        </div>

        <div class="summary-card card-customers">
          <div class="card-icon">
            <i class="bi bi-people"></i>
          </div>
          <div class="card-content">
            <p class="card-label">Active Customers</p>
            <h2 class="card-value">{{ summary.activeCustomers.toLocaleString() }}</h2>
            <div class="card-trend trend-up">
              <i class="bi bi-arrow-up"></i>
              <span>{{ summary.customersGrowth }}% new</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Monthly Chart -->
      <div class="chart-section">
        <div class="chart-card">
          <div class="chart-header">
            <h3>Revenue Trend {{ selectedYear }}</h3>
            <div class="chart-options">
              <button class="chart-btn" :class="{ active: chartType === 'revenue' }" @click="chartType = 'revenue'">
                Revenue
              </button>
              <button class="chart-btn" :class="{ active: chartType === 'orders' }" @click="chartType = 'orders'">
                Orders
              </button>
            </div>
          </div>
          <div class="chart-container">
            <canvas ref="salesChart"></canvas>
          </div>
        </div>
      </div>

      <!-- Monthly Details Table -->
      <div class="table-card">
        <div class="table-header">
          <h3>Detail Penjualan Per Bulan</h3>
          <div class="search-box">
            <i class="bi bi-search"></i>
            <input type="text" placeholder="Cari bulan..." v-model="searchQuery" />
          </div>
        </div>

        <div v-if="loading" class="loading-state">
          <div class="spinner-border text-primary"></div>
          <p>Loading sales report...</p>
        </div>

        <div v-else class="table-responsive">
          <table class="sales-table">
            <thead>
              <tr>
                <th>Bulan</th>
                <th>Total Orders</th>
                <th>Revenue</th>
                <th>Average Order</th>
                <th>New Customers</th>
                <th>Growth</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="month in filteredMonths" :key="month.id">
                <td>
                  <div class="month-cell">
                    <div class="month-icon">
                      <i :class="month.icon"></i>
                    </div>
                    <div>
                      <div class="month-name">{{ month.name }}</div>
                      <div class="month-year">{{ selectedYear }}</div>
                    </div>
                  </div>
                </td>
                <td class="orders-count">{{ month.totalOrders }}</td>
                <td class="revenue-amount">${{ month.revenue.toLocaleString() }}</td>
                <td>${{ month.avgOrder.toLocaleString() }}</td>
                <td class="customers-count">{{ month.newCustomers }}</td>
                <td>
                  <div class="growth-badge" :class="month.growth >= 0 ? 'growth-positive' : 'growth-negative'">
                    <i :class="month.growth >= 0 ? 'bi bi-arrow-up' : 'bi bi-arrow-down'"></i>
                    {{ Math.abs(month.growth) }}%
                  </div>
                </td>
                <td>
                  <span class="status-badge" :class="'status-' + month.status">
                    {{ month.status }}
                  </span>
                </td>
                <td>
                  <button class="btn-view" @click="viewMonthDetails(month)" title="View Details">
                    <i class="bi bi-eye"></i>
                  </button>
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="total-row">
                <td><strong>TOTAL {{ selectedYear }}</strong></td>
                <td><strong>{{ summary.totalOrders }}</strong></td>
                <td><strong>${{ summary.totalRevenue.toLocaleString() }}</strong></td>
                <td><strong>${{ summary.avgOrderValue.toLocaleString() }}</strong></td>
                <td><strong>{{ summary.activeCustomers }}</strong></td>
                <td colspan="3"></td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>

      <!-- Top Products Section -->
      <div class="products-section">
        <div class="products-card">
          <div class="products-header">
            <h3>Top Selling Products {{ selectedYear }}</h3>
            <button class="view-all-btn">View All</button>
          </div>
          <div class="products-list">
            <div class="product-item" v-for="product in topProducts" :key="product.id">
              <div class="product-rank">{{ product.rank }}</div>
              <img :src="product.image" :alt="product.name" class="product-image" />
              <div class="product-info">
                <h4 class="product-name">{{ product.name }}</h4>
                <p class="product-category">{{ product.category }}</p>
              </div>
              <div class="product-stats">
                <div class="stat-item">
                  <span class="stat-label">Sold</span>
                  <span class="stat-value">{{ product.sold }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Revenue</span>
                  <span class="stat-value">${{ product.revenue.toLocaleString() }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import AdminLayout from '../../components/admin/AdminLayout.vue'
import Chart from 'chart.js/auto'

export default {
  name: 'SalesReport',
  components: {
    AdminLayout
  },
  setup() {
    const loading = ref(false)
    const selectedYear = ref(2025)
    const searchQuery = ref('')
    const chartType = ref('revenue')
    const salesChart = ref(null)
    let chartInstance = null

    const summary = ref({
      totalRevenue: 245450,
      totalOrders: 1567,
      avgOrderValue: 156.5,
      activeCustomers: 834,
      revenueGrowth: 23.5,
      ordersGrowth: 18.2,
      avgGrowth: -2.3,
      customersGrowth: 15.8
    })

    const monthlyData = ref([
      {
        id: 1,
        name: 'Januari',
        icon: 'bi bi-calendar-date',
        totalOrders: 145,
        revenue: 22450,
        avgOrder: 154.83,
        newCustomers: 78,
        growth: 15.2,
        status: 'completed'
      },
      {
        id: 2,
        name: 'Februari',
        icon: 'bi bi-calendar-date',
        totalOrders: 132,
        revenue: 20100,
        avgOrder: 152.27,
        newCustomers: 65,
        growth: -8.9,
        status: 'completed'
      },
      {
        id: 3,
        name: 'Maret',
        icon: 'bi bi-calendar-date',
        totalOrders: 156,
        revenue: 24300,
        avgOrder: 155.77,
        newCustomers: 82,
        growth: 18.2,
        status: 'completed'
      },
      {
        id: 4,
        name: 'April',
        icon: 'bi bi-calendar-date',
        totalOrders: 142,
        revenue: 21850,
        avgOrder: 153.87,
        newCustomers: 71,
        growth: -9.0,
        status: 'completed'
      },
      {
        id: 5,
        name: 'Mei',
        icon: 'bi bi-calendar-date',
        totalOrders: 167,
        revenue: 26200,
        avgOrder: 156.89,
        newCustomers: 91,
        growth: 17.6,
        status: 'completed'
      },
      {
        id: 6,
        name: 'Juni',
        icon: 'bi bi-calendar-date',
        totalOrders: 138,
        revenue: 21450,
        avgOrder: 155.43,
        newCustomers: 68,
        growth: -17.4,
        status: 'completed'
      },
      {
        id: 7,
        name: 'Juli',
        icon: 'bi bi-calendar-date',
        totalOrders: 151,
        revenue: 23550,
        avgOrder: 155.96,
        newCustomers: 75,
        growth: 9.4,
        status: 'completed'
      },
      {
        id: 8,
        name: 'Agustus',
        icon: 'bi bi-calendar-date',
        totalOrders: 159,
        revenue: 24900,
        avgOrder: 156.60,
        newCustomers: 84,
        growth: 5.3,
        status: 'completed'
      },
      {
        id: 9,
        name: 'September',
        icon: 'bi bi-calendar-date',
        totalOrders: 144,
        revenue: 22300,
        avgOrder: 154.86,
        newCustomers: 72,
        growth: -9.4,
        status: 'completed'
      },
      {
        id: 10,
        name: 'Oktober',
        icon: 'bi bi-calendar-date',
        totalOrders: 161,
        revenue: 25150,
        avgOrder: 156.21,
        newCustomers: 86,
        growth: 11.8,
        status: 'completed'
      },
      {
        id: 11,
        name: 'November',
        icon: 'bi bi-calendar-date',
        totalOrders: 148,
        revenue: 23100,
        avgOrder: 156.08,
        newCustomers: 74,
        growth: -8.1,
        status: 'completed'
      },
      {
        id: 12,
        name: 'Desember',
        icon: 'bi bi-calendar-date',
        totalOrders: 124,
        revenue: 19100,
        avgOrder: 154.03,
        newCustomers: 58,
        growth: -16.2,
        status: 'ongoing'
      }
    ])

    const topProducts = ref([
      {
        id: 1,
        rank: 1,
        name: 'Wireless Earbuds Pro',
        category: 'Electronics',
        image: 'https://via.placeholder.com/60',
        sold: 1245,
        revenue: 74700
      },
      {
        id: 2,
        rank: 2,
        name: 'Smart Watch X1',
        category: 'Wearables',
        image: 'https://via.placeholder.com/60',
        sold: 987,
        revenue: 59220
      },
      {
        id: 3,
        rank: 3,
        name: 'Premium Backpack',
        category: 'Accessories',
        image: 'https://via.placeholder.com/60',
        sold: 856,
        revenue: 42800
      },
      {
        id: 4,
        rank: 4,
        name: 'Gaming Mouse RGB',
        category: 'Gaming',
        image: 'https://via.placeholder.com/60',
        sold: 745,
        revenue: 37250
      },
      {
        id: 5,
        rank: 5,
        name: 'USB-C Hub',
        category: 'Electronics',
        image: 'https://via.placeholder.com/60',
        sold: 623,
        revenue: 31150
      }
    ])

    const filteredMonths = computed(() => {
      if (!searchQuery.value) return monthlyData.value
      return monthlyData.value.filter(m =>
        m.name.toLowerCase().includes(searchQuery.value.toLowerCase())
      )
    })

    const initChart = () => {
      if (!salesChart.value) return

      const ctx = salesChart.value.getContext('2d')

      if (chartInstance) {
        chartInstance.destroy()
      }

      const labels = monthlyData.value.map(m => m.name)
      const data = chartType.value === 'revenue'
        ? monthlyData.value.map(m => m.revenue)
        : monthlyData.value.map(m => m.totalOrders)

      chartInstance = new Chart(ctx, {
        type: 'bar',
        data: {
          labels,
          datasets: [{
            label: chartType.value === 'revenue' ? 'Revenue ($)' : 'Orders',
            data,
            backgroundColor: 'rgba(16, 185, 129, 0.8)',
            borderColor: '#10b981',
            borderWidth: 2,
            borderRadius: 8,
            barThickness: 40
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            },
            tooltip: {
              backgroundColor: '#fff',
              titleColor: '#1f2937',
              bodyColor: '#6b7280',
              borderColor: '#e5e7eb',
              borderWidth: 1,
              padding: 12,
              displayColors: false,
              callbacks: {
                label: function(context) {
                  if (chartType.value === 'revenue') {
                    return 'Revenue: $' + context.parsed.y.toLocaleString()
                  }
                  return 'Orders: ' + context.parsed.y
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                color: '#f3f4f6',
                drawBorder: false
              },
              ticks: {
                callback: function(value) {
                  if (chartType.value === 'revenue') {
                    return '$' + (value / 1000) + 'K'
                  }
                  return value
                },
                color: '#6b7280'
              }
            },
            x: {
              grid: {
                display: false
              },
              ticks: {
                color: '#6b7280'
              }
            }
          }
        }
      })
    }

    const loadReport = async () => {
      loading.value = true
      try {
        // TODO: Fetch from API
        await new Promise(resolve => setTimeout(resolve, 500))
      } catch (error) {
        console.error('Failed to load report:', error)
      } finally {
        loading.value = false
      }
    }

    const exportToExcel = () => {
      alert('Export to Excel - Coming soon!')
    }

    const exportToPDF = () => {
      alert('Export to PDF - Coming soon!')
    }

    const viewMonthDetails = (month) => {
      alert(`View details for ${month.name} ${selectedYear.value}`)
    }

    watch(chartType, () => {
      initChart()
    })

    onMounted(() => {
      setTimeout(() => {
        initChart()
      }, 100)
    })

    return {
      loading,
      selectedYear,
      searchQuery,
      chartType,
      salesChart,
      summary,
      monthlyData,
      topProducts,
      filteredMonths,
      loadReport,
      exportToExcel,
      exportToPDF,
      viewMonthDetails
    }
  }
}
</script>

<style scoped>
.sales-report {
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

.year-select {
  padding: 10px 16px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  background: #fff;
  font-weight: 500;
}

.export-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: #10b981;
  color: #fff;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.export-btn:hover {
  background: #059669;
}

.btn-pdf {
  background: #ef4444;
}

.btn-pdf:hover {
  background: #dc2626;
}

.summary-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.summary-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  display: flex;
  gap: 20px;
  border: 1px solid #e5e7eb;
  transition: all 0.2s;
}

.summary-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.card-icon {
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  font-size: 28px;
  flex-shrink: 0;
}

.card-revenue .card-icon {
  background: #d1fae5;
  color: #10b981;
}

.card-orders .card-icon {
  background: #dbeafe;
  color: #3b82f6;
}

.card-average .card-icon {
  background: #fef3c7;
  color: #f59e0b;
}

.card-customers .card-icon {
  background: #ddd6fe;
  color: #8b5cf6;
}

.card-content {
  flex: 1;
}

.card-label {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 8px;
}

.card-value {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 8px;
  line-height: 1;
}

.card-trend {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 500;
}

.trend-up {
  color: #10b981;
}

.trend-down {
  color: #ef4444;
}

.chart-section {
  margin-bottom: 30px;
}

.chart-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #e5e7eb;
}

.chart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.chart-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.chart-options {
  display: flex;
  gap: 8px;
}

.chart-btn {
  padding: 8px 16px;
  background: #f3f4f6;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.chart-btn.active {
  background: #10b981;
  color: #fff;
}

.chart-container {
  height: 350px;
}

.table-card {
  background: #fff;
  border-radius: 16px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
  margin-bottom: 30px;
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
  width: 250px;
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

.table-responsive {
  overflow-x: auto;
}

.sales-table {
  width: 100%;
  border-collapse: collapse;
}

.sales-table th {
  text-align: left;
  padding: 16px 24px;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
  white-space: nowrap;
}

.sales-table td {
  padding: 16px 24px;
  font-size: 14px;
  color: #1f2937;
  border-bottom: 1px solid #f3f4f6;
}

.month-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.month-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #eff6ff;
  border-radius: 8px;
  color: #3b82f6;
  font-size: 18px;
}

.month-name {
  font-weight: 600;
  color: #1f2937;
}

.month-year {
  font-size: 12px;
  color: #6b7280;
}

.orders-count,
.customers-count {
  font-weight: 600;
  color: #3b82f6;
}

.revenue-amount {
  font-weight: 700;
  color: #10b981;
}

.growth-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

.growth-positive {
  background: #d1fae5;
  color: #065f46;
}

.growth-negative {
  background: #fee2e2;
  color: #991b1b;
}

.status-badge {
  display: inline-block;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.status-completed {
  background: #d1fae5;
  color: #065f46;
}

.status-ongoing {
  background: #fef3c7;
  color: #92400e;
}

.btn-view {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #eff6ff;
  color: #3b82f6;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-view:hover {
  background: #dbeafe;
}

.total-row {
  background: #f9fafb;
  font-weight: 600;
}

.total-row td {
  border-top: 2px solid #e5e7eb;
  color: #1f2937;
}

.products-section {
  margin-bottom: 30px;
}

.products-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  border: 1px solid #e5e7eb;
}

.products-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.products-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.view-all-btn {
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
}

.products-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.product-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: #f9fafb;
  border-radius: 12px;
  transition: all 0.2s;
}

.product-item:hover {
  background: #f3f4f6;
}

.product-rank {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #10b981;
  color: #fff;
  border-radius: 8px;
  font-weight: 700;
  font-size: 16px;
}

.product-image {
  width: 60px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
}

.product-info {
  flex: 1;
}

.product-name {
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 4px;
}

.product-category {
  font-size: 13px;
  color: #6b7280;
  margin: 0;
}

.product-stats {
  display: flex;
  gap: 24px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.stat-label {
  font-size: 12px;
  color: #6b7280;
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: #1f2937;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 16px;
  }

  .header-actions {
    width: 100%;
    flex-wrap: wrap;
  }

  .year-select,
  .export-btn {
    flex: 1;
  }

  .summary-grid {
    grid-template-columns: 1fr;
  }

  .search-box {
    width: 100%;
  }

  .product-stats {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
