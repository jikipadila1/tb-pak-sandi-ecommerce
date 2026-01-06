<template>
  <div class="cart">
    <div class="container mt-4">
      <h2 class="mb-4">Keranjang Belanja</h2>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Memuat...</span>
        </div>
      </div>

      <div v-else-if="items.length === 0" class="text-center py-5">
        <i class="bi bi-cart-x" style="font-size: 4rem; color: #ccc;"></i>
        <h3 class="mt-3">Keranjang Anda kosong</h3>
        <p class="text-muted">Tambahkan beberapa produk untuk memulai!</p>
        <router-link to="/products" class="btn btn-primary mt-3">
          <i class="bi bi-shop me-2"></i>Lanjut Belanja
        </router-link>
      </div>

      <div v-else class="row">
        <div class="col-md-8">
          <div class="card mb-3" v-for="item in items" :key="item.id">
            <div class="card-body">
              <div class="row align-items-center">
                <div class="col-md-2">
                  <img
                    :src="item.image || 'https://via.placeholder.com/100'"
                    :alt="item.name"
                    class="img-fluid rounded"
                  />
                </div>
                <div class="col-md-4">
                  <h5 class="mb-1">{{ item.name }}</h5>
                  <p class="text-muted mb-0">{{ formatRupiah(item.price) }} /pcs</p>
                  <small class="text-muted">Stok: {{ item.stock }}</small>
                </div>
                <div class="col-md-3">
                  <div class="input-group input-group-sm">
                    <button
                      class="btn btn-outline-secondary"
                      @click="updateQuantity(item.id, Number(item.quantity) - 1)"
                      :disabled="Number(item.quantity) <= 1 || isItemUpdating(item.id)"
                    >
                      <i class="bi bi-dash"></i>
                    </button>
                    
                    <input
                      type="number"
                      class="form-control text-center"
                      :value="item.quantity"
                      readonly
                    />

                    <button
                      class="btn btn-outline-secondary"
                      @click="updateQuantity(item.id, Number(item.quantity) + 1)"
                      :disabled="Number(item.quantity) >= item.stock || isItemUpdating(item.id)"
                    >
                      <i class="bi bi-plus"></i>
                    </button>
                  </div>
                </div>
                <div class="col-md-2">
                  <h5 class="text-primary mb-0">
                    {{ formatRupiah(parseFloat(item.price) * item.quantity) }}
                  </h5>
                </div>
                <div class="col-md-1 text-end">
                  <button
                    @click="removeItem(item.id)"
                    class="btn btn-sm btn-outline-danger"
                    :disabled="isItemUpdating(item.id)"
                  >
                    <i class="bi bi-trash"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <button @click="clearAllItems" class="btn btn-outline-danger" :disabled="updating">
            <i class="bi bi-trash me-2"></i>Kosongkan Keranjang
          </button>
        </div>

        <div class="col-md-4">
          <div class="card sticky-top" style="top: 20px;">
            <div class="card-body">
              <h5 class="card-title">Ringkasan Pesanan</h5>
              <hr />
              <div class="d-flex justify-content-between mb-2">
                <span>Subtotal ({{ items.length }} barang):</span>
                <span>{{ formatRupiah(total) }}</span>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Pengiriman:</span>
                <span class="text-success">GRATIS</span>
              </div>
              <hr />
              <div class="d-flex justify-content-between mb-3">
                <strong>Total:</strong>
                <strong class="text-primary">{{ formatRupiah(total) }}</strong>
              </div>
              <router-link to="/checkout" class="btn btn-primary w-100 btn-lg">
                <i class="bi bi-credit-card me-2"></i>Lanjut ke Pembayaran
              </router-link>
              <router-link to="/products" class="btn btn-outline-primary w-100 mt-2">
                <i class="bi bi-arrow-left me-2"></i>Lanjut Belanja
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed, onMounted, ref } from 'vue'
import { useCartStore } from '../store/cart'
import { formatRupiah } from '../utils/currency'

export default {
  name: 'Cart',
  setup() {
    const cartStore = useCartStore()
    const updating = ref(false)
    const updatingItems = ref(new Set())

    const items = computed(() => cartStore.items)
    const total = computed(() => cartStore.total)
    const loading = computed(() => cartStore.loading)

    const updateQuantity = async (itemId, quantity) => {
      // Konversi quantity ke Number untuk mencegah bug "1" + 1 = "11"
      const targetQty = Number(quantity)

      if (targetQty < 1) return

      if (updatingItems.value.has(itemId)) return

      const item = items.value.find(i => i.id === itemId)
      if (!item) return

      // Validasi stok
      if (targetQty > item.stock) {
        alert(`Jumlah maksimal yang bisa dipesan adalah ${item.stock}`)
        return
      }

      updatingItems.value.add(itemId)
      updating.value = true

      try {
        await cartStore.updateCartItem(itemId, targetQty)
      } catch (error) {
        const errorMsg = error.response?.data?.message || 'Gagal memperbarui keranjang'
        alert(errorMsg)
      } finally {
        updatingItems.value.delete(itemId)
        updating.value = updatingItems.value.size > 0
      }
    }

    const removeItem = async (itemId) => {
      if (!confirm('Hapus produk ini dari keranjang?')) return
      if (updatingItems.value.has(itemId)) return

      updatingItems.value.add(itemId)
      updating.value = true

      try {
        await cartStore.removeFromCart(itemId)
      } catch (error) {
        alert('Gagal menghapus produk')
      } finally {
        updatingItems.value.delete(itemId)
        updating.value = updatingItems.value.size > 0
      }
    }

    const clearAllItems = async () => {
      if (!confirm('Anda yakin ingin mengosongkan keranjang?')) return
      updating.value = true
      try {
        await cartStore.clearCart()
      } catch (error) {
        alert('Gagal mengosongkan keranjang')
      } finally {
        updating.value = false
      }
    }

    const isItemUpdating = (itemId) => {
      return updatingItems.value.has(itemId)
    }

    onMounted(() => {
      cartStore.fetchCart()
    })

    return {
      items,
      total,
      loading,
      updating,
      updateQuantity,
      removeItem,
      clearAllItems,
      isItemUpdating,
      formatRupiah
    }
  }
}
</script>