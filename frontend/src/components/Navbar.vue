<template>
  <nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
      <router-link class="navbar-brand" to="/">TB E-Commerce</router-link>
      
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
        <span class="navbar-toggler-icon"></span>
      </button>
      
      <div class="collapse navbar-collapse" id="navbarNav">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item">
            <router-link class="nav-link" to="/">Beranda</router-link>
          </li>
          <li class="nav-item">
            <router-link class="nav-link" to="/products">Produk</router-link>
          </li>

          <template v-if="isAuthenticated">
            <li class="nav-item">
              <router-link class="nav-link" to="/cart">
                Keranjang <span class="badge bg-light text-dark">{{ cartItemCount }}</span>
              </router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link" to="/orders">Pesanan</router-link>
            </li>
            <li class="nav-item" v-if="isAdmin">
              <router-link class="nav-link bg-warning text-dark px-3 rounded" to="/admin">
                <i class="bi bi-speedometer2"></i> Admin
              </router-link>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="#" @click.prevent="handleLogout">Keluar</a>
            </li>
          </template>

          <template v-else>
            <li class="nav-item">
              <router-link class="nav-link" to="/login">Masuk</router-link>
            </li>
            <li class="nav-item">
              <router-link class="nav-link" to="/register">Daftar</router-link>
            </li>
          </template>
        </ul>
      </div>
    </div>
  </nav>
</template>

<script>
import { computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../store/auth'
import { useCartStore } from '../store/cart'

export default {
  name: 'Navbar',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    const cartStore = useCartStore()

    const isAuthenticated = computed(() => authStore.isAuthenticated)
    const isAdmin = computed(() => authStore.user?.role === 'admin')
    const cartItemCount = computed(() => cartStore.itemCount)

    const handleLogout = () => {
      authStore.logout()
      router.push('/login')
    }

    // Fetch cart when component mounts if user is authenticated
    onMounted(() => {
      if (isAuthenticated.value) {
        console.log('Navbar: User authenticated, fetching cart...')
        cartStore.fetchCart()
      }
    })

    // Watch for authentication changes and fetch cart when user logs in
    watch(isAuthenticated, (newValue) => {
      if (newValue) {
        console.log('Navbar: User logged in, fetching cart...')
        cartStore.fetchCart()
      }
    })

    return {
      isAuthenticated,
      isAdmin,
      cartItemCount,
      handleLogout
    }
  }
}
</script>
