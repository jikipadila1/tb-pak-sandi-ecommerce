<template>
  <div class="register">
    <div class="container mt-5">
      <div class="row justify-content-center">
        <div class="col-md-6">
          <div class="card shadow">
            <div class="card-body p-5">
              <h2 class="text-center mb-4">Register</h2>

              <div v-if="success" class="alert alert-success">
                <strong>✅ Registration Successful!</strong><br>
                {{ success }}
              </div>

              <div v-if="error" class="alert alert-danger">
                <strong>❌ Registration Failed</strong><br>
                <div v-html="error"></div>
              </div>

              <form @submit.prevent="handleRegister">
                <div class="mb-3">
                  <label for="name" class="form-label">Full Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="name"
                    v-model="form.name"
                    required
                  />
                </div>

                <div class="mb-3">
                  <label for="email" class="form-label">Email</label>
                  <input
                    type="email"
                    class="form-control"
                    id="email"
                    v-model="form.email"
                    required
                  />
                </div>

                <div class="mb-3">
                  <label for="password" class="form-label">Password</label>
                  <input
                    type="password"
                    class="form-control"
                    id="password"
                    v-model="form.password"
                    required
                  />
                </div>

                <div class="mb-3">
                  <label for="password_confirm" class="form-label">Confirm Password</label>
                  <input
                    type="password"
                    class="form-control"
                    id="password_confirm"
                    v-model="form.password_confirm"
                    required
                  />
                </div>

                <button type="submit" class="btn btn-primary w-100" :disabled="loading">
                  <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
                  Register
                </button>
              </form>

              <div class="text-center mt-3">
                <p>Already have an account? <router-link to="/login">Login here</router-link></p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../store/auth'

export default {
  name: 'Register',
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()

    const form = ref({
      name: '',
      email: '',
      password: '',
      password_confirm: ''
    })

    const loading = ref(false)
    const error = ref(null)
    const success = ref(null)

    const handleRegister = async () => {
      // Reset messages
      error.value = null
      success.value = null

      // Validate passwords match
      if (form.value.password !== form.value.password_confirm) {
        error.value = 'Passwords do not match!'
        return
      }

      // Validate password length
      if (form.value.password.length < 6) {
        error.value = 'Password must be at least 6 characters long!'
        return
      }

      // Validate name length
      if (form.value.name.length < 3) {
        error.value = 'Name must be at least 3 characters long!'
        return
      }

      loading.value = true

      try {
        console.log('🚀 Starting registration...', form.value)
        const response = await authStore.register(form.value)
        console.log('✅ Registration successful!', response)

        // Show success message with auto-login info
        success.value = 'You are now logged in! Redirecting to home page...'

        // Redirect after short delay to show success message
        setTimeout(() => {
          router.push('/')
        }, 1500)
      } catch (err) {
        console.error('❌ Registration error:', err)
        console.error('Error response:', err.response)
        console.error('Error data:', err.response?.data)

        // Parse and display detailed error messages
        if (err.response?.data?.errors) {
          // Display validation errors from backend
          const errors = err.response.data.errors
          const errorList = Object.keys(errors).map(field => {
            return `<li>${errors[field]}</li>`
          }).join('')
          error.value = `<ul class="mb-0">${errorList}</ul>`
        } else if (err.response?.data?.message) {
          error.value = err.response.data.message
        } else {
          error.value = 'Registration failed. Please check your connection and try again.'
          console.error('Full error object:', err)
        }
        loading.value = false
      }
    }

    return {
      form,
      loading,
      error,
      success,
      handleRegister
    }
  }
}
</script>
