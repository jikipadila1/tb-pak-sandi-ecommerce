<template>
  <div class="card mb-3">
    <div class="row g-0">
      <div class="col-md-2">
        <img :src="item.image || '/placeholder.jpg'" class="img-fluid rounded-start" :alt="item.name" />
      </div>
      <div class="col-md-10">
        <div class="card-body">
          <div class="d-flex justify-content-between">
            <div>
              <h5 class="card-title">{{ item.name }}</h5>
              <p class="card-text text-muted">${{ item.price }} each</p>
            </div>
            <div>
              <button @click="$emit('remove', item.id)" class="btn btn-danger btn-sm">Remove</button>
            </div>
          </div>
          <div class="d-flex justify-content-between align-items-center mt-2">
            <div class="input-group" style="width: 150px;">
              <button class="btn btn-outline-secondary btn-sm" @click="updateQty(item.quantity - 1)">-</button>
              <input type="number" class="form-control form-control-sm text-center" :value="item.quantity" readonly />
              <button class="btn btn-outline-secondary btn-sm" @click="updateQty(item.quantity + 1)">+</button>
            </div>
            <strong class="text-primary">${{ (item.price * item.quantity).toFixed(2) }}</strong>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CartItem',
  props: {
    item: {
      type: Object,
      required: true
    }
  },
  emits: ['update', 'remove'],
  methods: {
    updateQty(qty) {
      if (qty > 0 && qty <= this.item.stock) {
        this.$emit('update', this.item.id, qty)
      }
    }
  }
}
</script>
