<template>
  <div class="admin-layout">
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="sidebar-header">
        <div class="logo">
          <i class="bi bi-shop"></i>
          <span class="logo-text">subcom</span>
        </div>
        <button class="menu-toggle" @click="toggleSidebar">
          <i class="bi bi-list"></i>
        </button>
      </div>

      <nav class="sidebar-nav">
        <div class="nav-section">
          <p class="nav-section-title">MENU UTAMA</p>
          <router-link to="/admin" class="nav-item" exact-active-class="active">
            <i class="bi bi-speedometer2"></i>
            <span>Dashboard</span>
          </router-link>
          <router-link to="/admin/orders" class="nav-item" active-class="active">
            <i class="bi bi-bag-check"></i>
            <span>Pesanan</span>
            <span class="badge badge-info">5</span>
          </router-link>
          <router-link to="/admin/reviews" class="nav-item" active-class="active">
            <i class="bi bi-star"></i>
            <span>Review</span>
            <span class="badge">02</span>
          </router-link>
          <router-link to="/admin/payment-confirmations" class="nav-item" active-class="active">
            <i class="bi bi-credit-card-2-front"></i>
            <span>Payment Confirm</span>
            <span class="badge badge-warning">12</span>
          </router-link>
          <router-link to="/admin/sales-report" class="nav-item" active-class="active">
            <i class="bi bi-graph-up-arrow"></i>
            <span>Laporan Penjualan</span>
          </router-link>
        </div>
      </nav>

      <div class="sidebar-footer">
        <button class="logout-btn" @click="handleLogout">
          <i class="bi bi-box-arrow-left"></i>
          <span>Logout</span>
        </button>
      </div>
    </aside>

    <!-- Main Content -->
    <div class="main-content">
      <!-- Top Header -->
      <header class="top-header">
        <div class="search-bar">
          <i class="bi bi-search"></i>
          <input type="text" placeholder="Search" />
        </div>

        <div class="header-actions">
          <button class="icon-btn">
            <i class="bi bi-sliders"></i>
          </button>
          <button class="icon-btn">
            <i class="bi bi-arrow-repeat"></i>
          </button>
          <button class="icon-btn">
            <i class="bi bi-moon"></i>
          </button>
          <button class="icon-btn">
            <i class="bi bi-bell"></i>
          </button>
          <div class="user-avatar">
            <img src="https://i.pravatar.cc/40" alt="User" />
          </div>
        </div>
      </header>

      <!-- Content Area -->
      <div class="content-area">
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script>
import { useRouter } from 'vue-router'

export default {
  name: 'AdminLayout',
  setup() {
    const router = useRouter()

    const toggleSidebar = () => {
      document.querySelector('.sidebar').classList.toggle('collapsed')
    }

    const handleLogout = () => {
      // Clear auth token
      localStorage.removeItem('token')
      router.push('/login')
    }

    return {
      toggleSidebar,
      handleLogout
    }
  }
}
</script>

<style scoped>
.admin-layout {
  display: flex;
  min-height: 100vh;
  background: #f8f9fa;
}

/* Sidebar Styles */
.sidebar {
  width: 260px;
  background: #1a1d29;
  color: #fff;
  display: flex;
  flex-direction: column;
  position: fixed;
  height: 100vh;
  overflow-y: auto;
  transition: all 0.3s ease;
  z-index: 1000;
}

.sidebar-header {
  padding: 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 20px;
  font-weight: 600;
}

.logo i {
  font-size: 28px;
  color: #10b981;
}

.menu-toggle {
  background: none;
  border: none;
  color: #fff;
  font-size: 24px;
  cursor: pointer;
  padding: 0;
  display: none;
}

.sidebar-nav {
  flex: 1;
  padding: 20px 0;
  overflow-y: auto;
}

.nav-section {
  margin-bottom: 30px;
}

.nav-section-title {
  font-size: 11px;
  font-weight: 600;
  color: #6b7280;
  padding: 0 20px;
  margin-bottom: 10px;
  letter-spacing: 0.5px;
}

.nav-item {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  color: #9ca3af;
  text-decoration: none;
  transition: all 0.2s;
  position: relative;
}

.nav-item i {
  font-size: 20px;
  margin-right: 12px;
  width: 20px;
}

.nav-item:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
}

.nav-item.active {
  background: #10b981;
  color: #fff;
}

.nav-item .badge {
  margin-left: auto;
  background: #ef4444;
  color: white;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
}

.nav-item .badge-warning {
  background: #f59e0b;
}

.nav-item .badge-info {
  background: #3b82f6;
}

.sidebar-footer {
  padding: 20px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.logout-btn {
  display: flex;
  align-items: center;
  width: 100%;
  padding: 12px 20px;
  background: rgba(239, 68, 68, 0.1);
  border: none;
  color: #ef4444;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.logout-btn i {
  margin-right: 12px;
  font-size: 20px;
}

.logout-btn:hover {
  background: rgba(239, 68, 68, 0.2);
}

/* Main Content Styles */
.main-content {
  flex: 1;
  margin-left: 260px;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.top-header {
  background: #fff;
  padding: 16px 30px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  position: sticky;
  top: 0;
  z-index: 100;
}

.search-bar {
  display: flex;
  align-items: center;
  background: #f3f4f6;
  padding: 10px 16px;
  border-radius: 8px;
  width: 400px;
}

.search-bar i {
  color: #6b7280;
  margin-right: 10px;
}

.search-bar input {
  border: none;
  background: none;
  outline: none;
  width: 100%;
  font-size: 14px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.icon-btn {
  background: none;
  border: none;
  color: #6b7280;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 6px;
  transition: all 0.2s;
}

.icon-btn:hover {
  background: #f3f4f6;
  color: #1f2937;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid #e5e7eb;
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.content-area {
  flex: 1;
  padding: 30px;
}

/* Responsive */
@media (max-width: 768px) {
  .sidebar {
    transform: translateX(-100%);
  }

  .sidebar.open {
    transform: translateX(0);
  }

  .main-content {
    margin-left: 0;
  }

  .menu-toggle {
    display: block;
  }

  .search-bar {
    width: 200px;
  }
}

/* Scrollbar Styling */
.sidebar-nav::-webkit-scrollbar {
  width: 6px;
}

.sidebar-nav::-webkit-scrollbar-track {
  background: rgba(255, 255, 255, 0.05);
}

.sidebar-nav::-webkit-scrollbar-thumb {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 3px;
}

.sidebar-nav::-webkit-scrollbar-thumb:hover {
  background: rgba(255, 255, 255, 0.3);
}
</style>
