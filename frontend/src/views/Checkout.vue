<template>
  <div class="checkout">
    <div class="container mt-4">
      <h2 class="mb-4">Pembayaran</h2>

      <div v-if="cartItems.length === 0" class="text-center py-5">
        <h4>Keranjang Anda kosong</h4>
        <router-link to="/products" class="btn btn-primary mt-3">Lihat Produk</router-link>
      </div>

      <div v-else class="row">
        <div class="col-md-8">
          <div class="card mb-4">
            <div class="card-header bg-primary text-white">
              <h5 class="mb-0"><i class="bi bi-geo-alt me-2"></i>Informasi Pengiriman</h5>
            </div>
            <div class="card-body">
              <form @submit.prevent="placeOrder">
                <div class="mb-3">
                  <label for="shipping_address" class="form-label">Alamat *</label>
                  <textarea
                    class="form-control"
                    id="shipping_address"
                    v-model="form.shipping_address"
                    rows="3"
                    required
                    placeholder="Masukkan alamat lengkap Anda"
                  ></textarea>
                </div>

                <div class="row">
                  <div class="col-md-6 mb-3">
                    <label for="shipping_city" class="form-label">Kota *</label>
                    <input
                      type="text"
                      class="form-control"
                      id="shipping_city"
                      v-model="form.shipping_city"
                      required
                      placeholder="Kota"
                    />
                  </div>

                  <div class="col-md-6 mb-3">
                    <label for="shipping_postal_code" class="form-label">Kode Pos *</label>
                    <input
                      type="text"
                      class="form-control"
                      id="shipping_postal_code"
                      v-model="form.shipping_postal_code"
                      required
                      placeholder="Kode Pos"
                    />
                  </div>
                </div>

                <div class="mb-3">
                  <label for="shipping_phone" class="form-label">Nomor Telepon *</label>
                  <input
                    type="tel"
                    class="form-control"
                    id="shipping_phone"
                    v-model="form.shipping_phone"
                    required
                    placeholder="+62812345678"
                  />
                </div>

                <div class="mb-3">
                  <label for="notes" class="form-label">Catatan Pesanan (Opsional)</label>
                  <textarea
                    class="form-control"
                    id="notes"
                    v-model="form.notes"
                    rows="2"
                    placeholder="Ada instruksi khusus?"
                  ></textarea>
                </div>
              </form>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="card sticky-top" style="top: 20px;">
            <div class="card-header bg-light">
              <h5 class="mb-0">Ringkasan Pesanan</h5>
            </div>
            <div class="card-body">
              <div class="mb-3">
                <h6 class="text-muted">Barang ({{ cartItems.length }})</h6>
                <div v-for="item in cartItems" :key="item.id" class="d-flex justify-content-between mb-2">
                  <span class="text-truncate me-2">{{ item.name }} x{{ item.quantity }}</span>
                  <span>{{ formatRupiah(item.price * item.quantity) }}</span>
                </div>
              </div>

              <hr />

              <div class="d-flex justify-content-between mb-2">
                <span>Subtotal:</span>
                <span>{{ formatRupiah(cartTotal) }}</span>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Pengiriman:</span>
                <span class="text-success">GRATIS</span>
              </div>
              <div class="d-flex justify-content-between mb-2">
                <span>Pajak:</span>
                <span>{{ formatRupiah(tax) }}</span>
              </div>

              <hr />

              <div class="d-flex justify-content-between mb-3">
                <strong>Total:</strong>
                <strong class="text-primary h5 mb-0">{{ formatRupiah(grandTotal) }}</strong>
              </div>

              <button
                @click="placeOrder"
                class="btn btn-primary w-100 btn-lg"
                :disabled="placing || !isFormValid"
              >
                <span v-if="placing" class="spinner-border spinner-border-sm me-2"></span>
                <i v-else class="bi bi-check-circle me-2"></i>
                {{ placing ? 'Memproses Pesanan...' : 'Lanjut Pembayaran' }}
              </button>

              <router-link to="/cart" class="btn btn-outline-secondary w-100 mt-2">
                <i class="bi bi-arrow-left me-2"></i>Kembali ke Keranjang
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '../store/cart'
import ordersApi from '../api/orders'
import { formatRupiah } from '../utils/currency'

export default {
  name: 'Checkout',
  setup() {
    const router = useRouter()
    const cartStore = useCartStore()

    const form = ref({
      shipping_address: '',
      shipping_city: '',
      shipping_postal_code: '',
      shipping_phone: '',
      notes: ''
    })

    const placing = ref(false)

    const cartItems = computed(() => cartStore.items)
    const cartTotal = computed(() => cartStore.total)
    const tax = computed(() => cartTotal.value * 0.1) // 10% tax
    const grandTotal = computed(() => cartTotal.value + tax.value)

    const isFormValid = computed(() => {
      return (
        form.value.shipping_address.trim() !== '' &&
        form.value.shipping_city.trim() !== '' &&
        form.value.shipping_postal_code.trim() !== '' &&
        form.value.shipping_phone.trim() !== ''
      )
    })

    const placeOrder = async () => {
      if (!isFormValid.value) {
        alert('Mohon lengkapi semua kolom yang wajib diisi')
        return
      }

      placing.value = true
      try {
        // Combine address, city, and postal code into one field
        const fullAddress = `${form.value.shipping_address}, ${form.value.shipping_city} ${form.value.shipping_postal_code}`

        const orderData = {
          shipping_address: fullAddress,
          shipping_phone: form.value.shipping_phone,
          notes: form.value.notes
        }

        console.log('Checkout: Placing order with data:', orderData)
        const response = await ordersApi.create(orderData)
        console.log('Checkout: Order response:', response.data)
        const orderId = response.data.data.order_id

        alert('Pesanan berhasil dibuat!')

        // Clear cart
        await cartStore.clearCart()

        // Redirect to order detail
        router.push(`/orders/${orderId}`)
      } catch (error) {
        console.error('Checkout: Failed to place order:', error)
        const errorMsg = error.response?.data?.message || 'Gagal membuat pesanan'
        alert(errorMsg)
      } finally {
        placing.value = false
      }
    }

    onMounted(() => {
      cartStore.fetchCart()
    })

    return {
      form,
      placing,
      cartItems,
      cartTotal,
      tax,
      grandTotal,
      isFormValid,
      placeOrder,
      formatRupiah
    }
  }
}
</script>
