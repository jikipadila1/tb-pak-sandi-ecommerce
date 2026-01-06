<template>
  <AdminLayout>
    <div class="dashboard">
      <!-- Welcome Header -->
      <div class="welcome-section">
        <div>
          <h1 class="welcome-title">Welcome Back, {{ username }}!</h1>
          <p class="welcome-subtitle">Here's what happening with your store today</p>
        </div>
        <div class="time-filter">
          <button class="filter-btn">Previous Year</button>
          <button class="filter-btn active">View All Time</button>
        </div>
      </div>

      <!-- Stats Cards -->
      <div class="stats-grid">
        <StatCard
          label="Ecommerce Revenue"
          :value="'$' + stats.revenue.toLocaleString()"
          change="16.9 %"
          changeText="(+$3,321 %)"
          icon="bi bi-currency-dollar"
          bg-class="bg-cream"
          trend="up"
        />
        <StatCard
          label="New Customers"
          :value="stats.newCustomers.toString()"
          change="-8.6 %"
          changeText=""
          icon="bi bi-people"
          bg-class="bg-green"
          trend="down"
        />
        <StatCard
          label="Repeat Purchase Rate"
          :value="stats.repeatRate + ' %'"
          change="25.6 %"
          changeText="(+20.11 %)"
          icon="bi bi-arrow-repeat"
          bg-class="bg-blue"
          trend="up"
        />
        <StatCard
          label="Average Order Value"
          :value="'$' + stats.avgOrder.toLocaleString()"
          change="35.2 %"
          changeText="(+ $754)"
          icon="bi bi-cart-check"
          bg-class="bg-purple"
          trend="up"
        />
        <StatCard
          label="Conversion rate"
          :value="stats.conversionRate + ' %'"
          change="-12.62 %"
          changeText=""
          icon="bi bi-graph-up"
          bg-class="bg-red"
          trend="down"
        />
      </div>

      <!-- Charts Section -->
      <div class="charts-section">
        <div class="chart-card summary-chart">
          <div class="chart-header">
            <h3 class="chart-title">Summary</h3>
            <div class="chart-legend">
              <button class="legend-item active">
                <span class="legend-dot order"></span>
                Order
              </button>
              <button class="legend-item">
                <span class="legend-dot income"></span>
                Income Growth
              </button>
              <select class="time-select">
                <option>Last 7 days</option>
                <option>Last 30 days</option>
                <option>Last 90 days</option>
              </select>
            </div>
          </div>
          <div class="chart-container">
            <canvas ref="summaryChart"></canvas>
          </div>
        </div>

        <div class="chart-card products-card">
          <div class="chart-header">
            <h3 class="chart-title">Most Selling Products</h3>
            <button class="more-btn">
              <i class="bi bi-three-dots"></i>
            </button>
          </div>
          <div class="products-list">
            <div class="product-item" v-for="product in topProducts" :key="product.id">
              <div class="product-info">
                <div class="product-icon" :style="{ background: product.color }">
                  <i :class="product.icon"></i>
                </div>
                <div>
                  <h4 class="product-name">{{ product.name }}</h4>
                  <p class="product-id">ID: {{ product.id }}</p>
                </div>
              </div>
              <div class="product-sales">{{ product.sales }} Sales</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Orders & Top Customers -->
      <div class="tables-section">
        <div class="table-card orders-card">
          <div class="table-header">
            <h3 class="table-title">Recent Orders</h3>
            <button class="view-all-btn" @click="$router.push('/admin/orders')">View All</button>
          </div>
          <div class="table-responsive">
            <table class="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Customer</th>
                  <th>Order ID</th>
                  <th>Date</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="order in recentOrders" :key="order.id">
                  <td>
                    <div class="product-cell">
                      <div class="product-image" :style="{ background: order.productColor }">
                        <i :class="order.productIcon"></i>
                      </div>
                      <span>{{ order.product }}</span>
                    </div>
                  </td>
                  <td>
                    <button class="customer-link">{{ order.customer }}</button>
                  </td>
                  <td class="order-id">#{{ order.orderId }}</td>
                  <td>{{ order.date }}</td>
                  <td>
                    <span class="status-badge" :class="'status-' + order.status.toLowerCase()">
                      <span class="status-dot"></span>
                      {{ order.status }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="table-card customers-card">
          <div class="table-header">
            <h3 class="table-title">Weekly Top Customers</h3>
            <button class="more-btn">
              <i class="bi bi-three-dots"></i>
            </button>
          </div>
          <div class="customers-list">
            <div class="customer-item" v-for="customer in topCustomers" :key="customer.id">
              <div class="customer-info">
                <img :src="customer.avatar" :alt="customer.name" class="customer-avatar" />
                <div>
                  <h4 class="customer-name">{{ customer.name }}</h4>
                  <p class="customer-orders">{{ customer.orders }} Orders</p>
                </div>
              </div>
              <button class="view-btn">View</button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </AdminLayout>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import AdminLayout from '../../components/admin/AdminLayout.vue'
import StatCard from '../../components/admin/StatCard.vue'
import Chart from 'chart.js/auto'

export default {
  name: 'AdminDashboard',
  components: {
    AdminLayout,
    StatCard
  },
  setup() {
    const router = useRouter()
    const summaryChart = ref(null)
    const username = ref('Mahfuzul')

    const stats = ref({
      revenue: 245450,
      newCustomers: 684,
      repeatRate: 75.12,
      avgOrder: 2412.23,
      conversionRate: 32.65
    })

    const topProducts = ref([
      {
        id: 2441310,
        name: 'Sticker Vento',
        sales: 128,
        icon: 'bi bi-clipboard',
        color: '#dbeafe'
      },
      {
        id: 1241238,
        name: 'Blue Backpack',
        sales: 401,
        icon: 'bi bi-backpack',
        color: '#ddd6fe'
      },
      {
        id: 8441573,
        name: 'Water Bottle',
        sales: '1K+',
        icon: 'bi bi-droplet',
        color: '#fef3c7'
      }
    ])

    const recentOrders = ref([
      {
        id: 1,
        product: 'Water Bottle',
        customer: 'Peterson Jack',
        orderId: '8441573',
        date: '27 Jun 2025',
        status: 'Pending',
        productIcon: 'bi bi-droplet',
        productColor: '#fef3c7'
      },
      {
        id: 2,
        product: 'Iphone 15 Pro',
        customer: 'Michal Datta',
        orderId: '2457841',
        date: '26 Jun 2025',
        status: 'Canceled',
        productIcon: 'bi bi-phone',
        productColor: '#fee2e2'
      },
      {
        id: 3,
        product: 'Headphone',
        customer: 'Jesiya Rose',
        orderId: '1024784',
        date: '20 Jun 2025',
        status: 'Shipped',
        productIcon: 'bi bi-headphones',
        productColor: '#dbeafe'
      }
    ])

    const topCustomers = ref([
      {
        id: 1,
        name: 'Marks Hoverson',
        orders: 25,
        avatar: 'https://i.pravatar.cc/40?img=1'
      },
      {
        id: 2,
        name: 'Marks Hoverson',
        orders: 15,
        avatar: 'https://i.pravatar.cc/40?img=2'
      },
      {
        id: 3,
        name: 'Jhony Peters',
        orders: 23,
        avatar: 'https://i.pravatar.cc/40?img=3'
      }
    ])

    const initChart = () => {
      if (!summaryChart.value) return

      const ctx = summaryChart.value.getContext('2d')

      new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['Sep 07', 'Sep 08', 'Sep 09', 'Sep 10', 'Sep 11', 'Sep 12', 'Sep 13'],
          datasets: [
            {
              label: 'Order',
              data: [4200, 5300, 4800, 3800, 5800, 4500, 6300],
              borderColor: '#3b82f6',
              backgroundColor: 'rgba(59, 130, 246, 0.1)',
              tension: 0.4,
              fill: true,
              borderWidth: 2
            },
            {
              label: 'Income Growth',
              data: [5500, 6200, 5800, 4200, 4800, 3500, 5200],
              borderColor: '#10b981',
              backgroundColor: 'rgba(16, 185, 129, 0.1)',
              tension: 0.4,
              fill: true,
              borderWidth: 2
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            },
            tooltip: {
              mode: 'index',
              intersect: false,
              backgroundColor: '#fff',
              titleColor: '#1f2937',
              bodyColor: '#6b7280',
              borderColor: '#e5e7eb',
              borderWidth: 1,
              padding: 12,
              displayColors: true,
              callbacks: {
                label: function(context) {
                  return context.dataset.label + ': $' + context.parsed.y.toLocaleString()
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
                  return value / 1000 + 'K'
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
          },
          interaction: {
            mode: 'nearest',
            axis: 'x',
            intersect: false
          }
        }
      })
    }

    onMounted(() => {
      setTimeout(() => {
        initChart()
      }, 100)
    })

    return {
      username,
      stats,
      topProducts,
      recentOrders,
      topCustomers,
      summaryChart
    }
  }
}
</script>

<style scoped>
.dashboard {
  max-width: 1400px;
}

.welcome-section {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 30px;
}

.welcome-title {
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 4px;
}

.welcome-subtitle {
  font-size: 14px;
  color: #6b7280;
}

.time-filter {
  display: flex;
  gap: 10px;
}

.filter-btn {
  padding: 10px 20px;
  border: 1px solid #e5e7eb;
  background: #fff;
  border-radius: 8px;
  font-size: 14px;
  color: #6b7280;
  cursor: pointer;
  transition: all 0.2s;
}

.filter-btn.active {
  background: #1f2937;
  color: #fff;
  border-color: #1f2937;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.charts-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
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
  margin-bottom: 20px;
}

.chart-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.chart-legend {
  display: flex;
  align-items: center;
  gap: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  font-size: 13px;
  color: #6b7280;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 6px;
  transition: all 0.2s;
}

.legend-item.active {
  background: #f3f4f6;
  color: #1f2937;
}

.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.legend-dot.order {
  background: #3b82f6;
}

.legend-dot.income {
  background: #10b981;
}

.time-select {
  padding: 6px 12px;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  font-size: 13px;
  color: #1f2937;
  cursor: pointer;
  background: #fff;
}

.chart-container {
  height: 300px;
}

.products-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.product-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #f9fafb;
  border-radius: 12px;
  transition: all 0.2s;
}

.product-item:hover {
  background: #f3f4f6;
}

.product-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-icon {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  font-size: 20px;
}

.product-name {
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 2px;
}

.product-id {
  font-size: 12px;
  color: #9ca3af;
}

.product-sales {
  font-size: 14px;
  font-weight: 600;
  color: #1f2937;
}

.more-btn {
  background: none;
  border: none;
  color: #6b7280;
  font-size: 20px;
  cursor: pointer;
  padding: 4px 8px;
  border-radius: 6px;
  transition: all 0.2s;
}

.more-btn:hover {
  background: #f3f4f6;
}

.tables-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
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

.table-title {
  font-size: 18px;
  font-weight: 600;
  color: #1f2937;
}

.view-all-btn {
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 6px;
  transition: all 0.2s;
}

.view-all-btn:hover {
  background: #eff6ff;
}

.table-responsive {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th {
  text-align: left;
  padding: 16px 24px;
  font-size: 13px;
  font-weight: 600;
  color: #6b7280;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}

.data-table td {
  padding: 16px 24px;
  font-size: 14px;
  color: #1f2937;
  border-bottom: 1px solid #f3f4f6;
}

.product-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.product-image {
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  font-size: 16px;
}

.customer-link {
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 14px;
  cursor: pointer;
  padding: 0;
  text-decoration: none;
}

.customer-link:hover {
  text-decoration: underline;
}

.order-id {
  font-weight: 600;
}

.status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.status-pending {
  background: #fef3c7;
  color: #92400e;
}

.status-pending .status-dot {
  background: #f59e0b;
}

.status-shipped {
  background: #dbeafe;
  color: #1e40af;
}

.status-shipped .status-dot {
  background: #3b82f6;
}

.status-canceled {
  background: #fee2e2;
  color: #991b1b;
}

.status-canceled .status-dot {
  background: #ef4444;
}

.customers-list {
  padding: 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.customer-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.customer-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.customer-avatar {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  object-fit: cover;
}

.customer-name {
  font-size: 15px;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 2px;
}

.customer-orders {
  font-size: 13px;
  color: #6b7280;
}

.view-btn {
  background: none;
  border: none;
  color: #3b82f6;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  padding: 6px 12px;
  border-radius: 6px;
  transition: all 0.2s;
}

.view-btn:hover {
  background: #eff6ff;
}

@media (max-width: 1024px) {
  .charts-section,
  .tables-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .welcome-section {
    flex-direction: column;
    gap: 16px;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .time-filter {
    width: 100%;
  }

  .filter-btn {
    flex: 1;
  }
}
</style>
