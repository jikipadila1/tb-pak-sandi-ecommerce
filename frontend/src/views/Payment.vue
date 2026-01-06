<template>
  <div class="payment">
    <div class="container mt-4">
      <div class="row justify-content-center">
        <div class="col-md-8">
          <div class="card">
            <div class="card-header bg-primary text-white">
              <h4 class="mb-0"><i class="bi bi-credit-card me-2"></i>Pembayaran</h4>
            </div>
            <div class="card-body">
              <div v-if="loading" class="text-center py-5">
                <div class="spinner-border" role="status">
                  <span class="visually-hidden">Memuat...</span>
                </div>
              </div>

              <div v-else-if="order">
                <!-- Order Summary -->
                <div class="alert alert-info">
                  <h5><i class="bi bi-info-circle me-2"></i>Detail Pesanan</h5>
                  <div class="row">
                    <div class="col-6">
                      <strong>ID Pesanan:</strong> #{{ order.id }}
                    </div>
                    <div class="col-6 text-end">
                      <strong>Total:</strong>
                      <span class="text-primary fs-5">{{ formatRupiah(order.total_amount) }}</span>
                    </div>
                  </div>
                </div>

                <!-- Payment Methods -->
                <h5 class="mb-3">Pilih Metode Pembayaran</h5>
                <div class="payment-methods">
                  <div
                    v-for="method in paymentMethods"
                    :key="method.id"
                    class="payment-method-card"
                    :class="{ active: selectedMethod === method.id }"
                    @click="selectedMethod = method.id"
                  >
                    <div class="card mb-3" style="cursor: pointer;">
                      <div class="card-body d-flex align-items-center">
                        <div class="form-check me-3">
                          <input
                            class="form-check-input"
                            type="radio"
                            :value="method.id"
                            v-model="selectedMethod"
                            :id="'method-' + method.id"
                          />
                        </div>
                        <div class="flex-grow-1">
                          <h6 class="mb-1">
                            <i :class="method.icon + ' me-2'"></i>
                            {{ method.name }}
                          </h6>
                          <small class="text-muted">{{ method.description }}</small>
                        </div>
                        <div v-if="method.logo">
                          <img :src="method.logo" :alt="method.name" style="height: 30px;">
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Payment Form -->
                <div v-if="selectedMethod === 'credit_card'" class="mt-4">
                  <h5 class="mb-3">Informasi Kartu</h5>
                  <form @submit.prevent="processPayment">
                    <div class="mb-3">
                      <label for="card_number" class="form-label">Nomor Kartu</label>
                      <input
                        type="text"
                        class="form-control"
                        id="card_number"
                        v-model="paymentForm.card_number"
                        placeholder="1234 5678 9012 3456"
                        maxlength="19"
                        required
                      />
                    </div>

                    <div class="row">
                      <div class="col-md-6 mb-3">
                        <label for="card_holder" class="form-label">Nama Pemegang Kartu</label>
                        <input
                          type="text"
                          class="form-control"
                          id="card_holder"
                          v-model="paymentForm.card_holder"
                          placeholder="NAMA LENGKAP"
                          required
                        />
                      </div>
                      <div class="col-md-3 mb-3">
                        <label for="expiry" class="form-label">Berlaku Hingga</label>
                        <input
                          type="text"
                          class="form-control"
                          id="expiry"
                          v-model="paymentForm.expiry"
                          placeholder="MM/YY"
                          maxlength="5"
                          required
                        />
                      </div>
                      <div class="col-md-3 mb-3">
                        <label for="cvv" class="form-label">CVV</label>
                        <input
                          type="text"
                          class="form-control"
                          id="cvv"
                          v-model="paymentForm.cvv"
                          placeholder="123"
                          maxlength="4"
                          required
                        />
                      </div>
                    </div>
                  </form>
                </div>

                <div v-if="selectedMethod === 'bank_transfer'" class="mt-4">
                  <div class="alert alert-warning">
                    <h5><i class="bi bi-bank me-2"></i>Instruksi Transfer Bank</h5>
                    <p class="mb-2">Silakan transfer ke salah satu rekening berikut:</p>
                    <div class="bg-white p-3 rounded mb-2">
                      <strong>Bank BCA</strong><br>
                      <strong>Nama Rekening:</strong> TB E-Commerce<br>
                      <strong>Nomor Rekening:</strong> 1234567890<br>
                    </div>
                    <div class="bg-white p-3 rounded mb-2">
                      <strong>Bank Mandiri</strong><br>
                      <strong>Nama Rekening:</strong> TB E-Commerce<br>
                      <strong>Nomor Rekening:</strong> 9876543210<br>
                    </div>
                    <div class="bg-white p-3 rounded">
                      <strong>Jumlah Transfer:</strong> <span class="text-danger fs-5">{{ formatRupiah(order.total_amount) }}</span>
                    </div>
                    <p class="mt-3 mb-0"><small><strong>Penting:</strong> Setelah transfer, silakan isi form konfirmasi pembayaran di bawah.</small></p>
                  </div>

                  <h5 class="mb-3">Form Konfirmasi Pembayaran</h5>

                  <div class="mb-3">
                    <label for="bank_name" class="form-label">Nama Bank Pengirim *</label>
                    <select class="form-select" id="bank_name" v-model="transferForm.bank_name" required>
                      <option value="">Pilih Bank</option>
                      <option value="BCA">BCA</option>
                      <option value="Mandiri">Mandiri</option>
                      <option value="BNI">BNI</option>
                      <option value="BRI">BRI</option>
                      <option value="CIMB">CIMB Niaga</option>
                      <option value="Others">Lainnya</option>
                    </select>
                  </div>

                  <div class="mb-3">
                    <label for="account_number" class="form-label">Nomor Rekening Pengirim *</label>
                    <input
                      type="text"
                      class="form-control"
                      id="account_number"
                      v-model="transferForm.account_number"
                      placeholder="1234567890"
                      required
                    />
                  </div>

                  <div class="mb-3">
                    <label for="account_holder" class="form-label">Nama Pemilik Rekening *</label>
                    <input
                      type="text"
                      class="form-control"
                      id="account_holder"
                      v-model="transferForm.account_holder"
                      placeholder="Nama sesuai rekening"
                      required
                    />
                  </div>

                  <div class="mb-3">
                    <label for="transfer_date" class="form-label">Tanggal Transfer *</label>
                    <input
                      type="date"
                      class="form-control"
                      id="transfer_date"
                      v-model="transferForm.transfer_date"
                      :max="new Date().toISOString().split('T')[0]"
                      required
                    />
                  </div>

                  <div class="mb-3">
                    <label for="transfer_amount" class="form-label">Jumlah yang Ditransfer *</label>
                    <input
                      type="number"
                      class="form-control"
                      id="transfer_amount"
                      v-model="transferForm.transfer_amount"
                      :placeholder="order.total_amount"
                      required
                    />
                    <small class="text-muted">Masukkan jumlah yang Anda transfer</small>
                  </div>

                  <div class="mb-3">
                    <label for="payment_proof" class="form-label">Unggah Bukti Transfer *</label>
                    <input
                      type="file"
                      class="form-control"
                      id="payment_proof"
                      @change="handleFileUpload"
                      accept="image/*"
                      required
                    />
                    <small class="text-muted">Format: JPG, PNG, maksimal 2MB</small>
                    <div v-if="proofPreview" class="mt-2">
                      <img :src="proofPreview" alt="Preview" style="max-width: 200px; border-radius: 8px;" />
                    </div>
                  </div>

                  <div class="mb-3">
                    <label for="notes" class="form-label">Catatan (Opsional)</label>
                    <textarea
                      class="form-control"
                      id="notes"
                      v-model="transferForm.notes"
                      rows="3"
                      placeholder="Tambahkan catatan jika diperlukan"
                    ></textarea>
                  </div>
                </div>

                <div v-if="selectedMethod === 'e_wallet'" class="mt-4">
                  <div class="alert alert-info">
                    <h5><i class="bi bi-wallet2 me-2"></i>Pembayaran E-Wallet</h5>
                    <p>Anda akan diarahkan untuk menyelesaikan pembayaran melalui aplikasi e-wallet.</p>
                  </div>
                </div>

                <div v-if="selectedMethod === 'cod'" class="mt-4">
                  <div class="alert alert-success">
                    <h5><i class="bi bi-cash me-2"></i>Bayar di Tempat (COD)</h5>
                    <p class="mb-0">Anda akan membayar saat pesanan diantar ke alamat Anda.</p>
                  </div>
                </div>

                <!-- Action Buttons -->
                <div class="d-grid gap-2 mt-4">
                  <button
                    @click="processPayment"
                    class="btn btn-primary btn-lg"
                    :disabled="processing || !selectedMethod"
                  >
                    <span v-if="processing" class="spinner-border spinner-border-sm me-2"></span>
                    <i v-else class="bi bi-check-circle me-2"></i>
                    {{ processing ? 'Memproses...' : 'Konfirmasi Pembayaran' }}
                  </button>

                  <router-link :to="`/orders/${orderId}`" class="btn btn-outline-secondary">
                    <i class="bi bi-arrow-left me-2"></i>Kembali ke Pesanan
                  </router-link>
                </div>
              </div>

              <div v-else class="text-center py-5">
                <i class="bi bi-exclamation-triangle text-warning" style="font-size: 3rem;"></i>
                <h4 class="mt-3">Pesanan tidak ditemukan</h4>
                <router-link to="/orders" class="btn btn-primary mt-3">Lihat Pesanan</router-link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import ordersApi from '../api/orders'
import paymentConfirmationsApi from '../api/paymentConfirmations'
import { formatRupiah } from '../utils/currency'

export default {
  name: 'Payment',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const orderId = route.params.id

    const order = ref(null)
    const loading = ref(true)
    const processing = ref(false)
    const selectedMethod = ref('')
    const paymentProof = ref(null)
    const proofPreview = ref(null)

    const paymentForm = ref({
      card_number: '',
      card_holder: '',
      expiry: '',
      cvv: ''
    })

    const transferForm = ref({
      bank_name: '',
      account_number: '',
      account_holder: '',
      transfer_date: new Date().toISOString().split('T')[0],
      transfer_amount: '',
      notes: ''
    })

    const paymentMethods = [
      {
        id: 'credit_card',
        name: 'Kartu Kredit/Debit',
        description: 'Bayar dengan aman menggunakan kartu',
        icon: 'bi bi-credit-card-2-front'
      },
      {
        id: 'bank_transfer',
        name: 'Transfer Bank',
        description: 'Transfer langsung ke rekening kami',
        icon: 'bi bi-bank'
      },
      {
        id: 'e_wallet',
        name: 'E-Wallet',
        description: 'GoPay, OVO, Dana, dll.',
        icon: 'bi bi-wallet2'
      },
      {
        id: 'cod',
        name: 'Bayar di Tempat',
        description: 'Bayar saat menerima pesanan',
        icon: 'bi bi-cash'
      }
    ]

    const handleFileUpload = (event) => {
      const file = event.target.files[0]
      if (file) {
        // Validate file size (max 2MB)
        if (file.size > 2 * 1024 * 1024) {
          alert('Ukuran file maksimal 2MB')
          event.target.value = ''
          return
        }

        paymentProof.value = file

        // Create preview
        const reader = new FileReader()
        reader.onload = (e) => {
          proofPreview.value = e.target.result
        }
        reader.readAsDataURL(file)
      }
    }

    const processPayment = async () => {
      if (!selectedMethod.value) {
        alert('Silakan pilih metode pembayaran')
        return
      }

      // Validate bank transfer form
      if (selectedMethod.value === 'bank_transfer') {
        if (!transferForm.value.bank_name || !transferForm.value.account_number ||
            !transferForm.value.account_holder || !transferForm.value.transfer_date ||
            !transferForm.value.transfer_amount || !paymentProof.value) {
          alert('Mohon lengkapi semua field yang wajib diisi')
          return
        }

        // Validate transfer amount
        if (parseFloat(transferForm.value.transfer_amount) !== parseFloat(order.value.total_amount)) {
          if (!confirm('Jumlah transfer tidak sesuai dengan total pesanan. Lanjutkan?')) {
            return
          }
        }
      }

      processing.value = true
      try {
        if (selectedMethod.value === 'bank_transfer') {
          // Submit payment confirmation to admin
          const confirmationData = {
            order_id: orderId,
            payment_method: 'Bank Transfer',
            bank_name: transferForm.value.bank_name,
            account_number: transferForm.value.account_number,
            account_holder: transferForm.value.account_holder,
            payment_date: transferForm.value.transfer_date,
            amount: transferForm.value.transfer_amount,
            notes: transferForm.value.notes
          }

          // Upload proof image (convert to base64 or handle file upload)
          if (paymentProof.value) {
            const reader = new FileReader()
            reader.onload = async (e) => {
              confirmationData.proof_image = e.target.result

              try {
                await paymentConfirmationsApi.submit(orderId, confirmationData)

                alert('✅ Konfirmasi pembayaran berhasil dikirim!\n\nPembayaran Anda akan diverifikasi oleh admin dalam 1x24 jam.')
                router.push(`/orders/${orderId}`)
              } catch (error) {
                const errorMsg = error.response?.data?.message || 'Gagal mengirim konfirmasi pembayaran'
                alert(errorMsg)
                processing.value = false
              }
            }
            reader.readAsDataURL(paymentProof.value)
            return
          }
        } else {
          // Other payment methods
          const formData = new FormData()
          formData.append('payment_method', selectedMethod.value)

          if (selectedMethod.value === 'credit_card') {
            formData.append('card_number', paymentForm.value.card_number)
            formData.append('card_holder', paymentForm.value.card_holder)
            formData.append('expiry', paymentForm.value.expiry)
            formData.append('cvv', paymentForm.value.cvv)
          }

          await ordersApi.createPayment(orderId, formData)
          alert('Pembayaran berhasil diproses!')
          router.push(`/orders/${orderId}`)
        }
      } catch (error) {
        const errorMsg = error.response?.data?.message || 'Gagal memproses pembayaran'
        alert(errorMsg)
      } finally {
        processing.value = false
      }
    }

    onMounted(async () => {
      try {
        const response = await ordersApi.getOrder(orderId)
        order.value = response.data.data
      } catch (error) {
        console.error('Failed to load order:', error)
      } finally {
        loading.value = false
      }
    })

    return {
      orderId,
      order,
      loading,
      processing,
      selectedMethod,
      paymentMethods,
      paymentForm,
      transferForm,
      proofPreview,
      handleFileUpload,
      processPayment,
      formatRupiah
    }
  }
}
</script>

<style scoped>
.payment-method-card.active .card {
  border-color: #0d6efd;
  background-color: #f8f9fa;
}

.payment-method-card .card:hover {
  border-color: #0d6efd;
  box-shadow: 0 0 10px rgba(13, 110, 253, 0.2);
}
</style>
