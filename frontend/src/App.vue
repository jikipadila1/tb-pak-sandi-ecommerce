<template>
  <div id="app">
    <Navbar />
    <router-view />
  </div>
</template>

<script>
import { onMounted } from 'vue'
import { useAuthStore } from './store/auth'
import { useCartStore } from './store/cart'
import Navbar from './components/Navbar.vue'

export default {
  name: 'App',
  components: {
    Navbar
  },
  setup() {
    const authStore = useAuthStore()
    const cartStore = useCartStore()

    onMounted(async () => {
      // Check if user is logged in
      if (authStore.token) {
        await authStore.fetchUser()
        if (authStore.isAuthenticated) {
          await cartStore.fetchCart()
        }
      }
    })
  }
}
</script>

<style>
body {
  margin: 0;
  padding: 0;
}

#app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

/* Custom Scrollbar Styling */
::-webkit-scrollbar {
  width: 12px;
  height: 12px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 10px;
}

::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #0d6efd 0%, #0052cc 100%);
  border-radius: 10px;
  border: 2px solid #f1f1f1;
}

::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #0052cc 0%, #003d99 100%);
}

::-webkit-scrollbar-thumb:active {
  background: linear-gradient(180deg, #003d99 0%, #002966 100%);
}

/* Firefox Scrollbar */
* {
  scrollbar-width: thin;
  scrollbar-color: #0d6efd #f1f1f1;
}
</style>
