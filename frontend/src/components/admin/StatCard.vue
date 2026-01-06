<template>
  <div class="stat-card" :class="bgClass">
    <div class="stat-header">
      <div class="stat-info">
        <p class="stat-label">{{ label }}</p>
        <h2 class="stat-value">{{ value }}</h2>
        <div class="stat-change" :class="changeClass">
          <i :class="changeIcon"></i>
          <span>{{ change }}</span>
          <span class="change-text">{{ changeText }}</span>
        </div>
      </div>
      <div class="stat-icon">
        <i :class="icon"></i>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StatCard',
  props: {
    label: {
      type: String,
      required: true
    },
    value: {
      type: String,
      required: true
    },
    change: {
      type: String,
      default: ''
    },
    changeText: {
      type: String,
      default: ''
    },
    icon: {
      type: String,
      required: true
    },
    bgClass: {
      type: String,
      default: 'bg-cream'
    },
    trend: {
      type: String,
      default: 'up', // 'up' or 'down'
      validator: (value) => ['up', 'down'].includes(value)
    }
  },
  computed: {
    changeClass() {
      return this.trend === 'up' ? 'change-up' : 'change-down'
    },
    changeIcon() {
      return this.trend === 'up' ? 'bi bi-arrow-up' : 'bi bi-arrow-down'
    }
  }
}
</script>

<style scoped>
.stat-card {
  background: #fff;
  border-radius: 16px;
  padding: 24px;
  transition: all 0.3s ease;
  border: 1px solid #e5e7eb;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.stat-info {
  flex: 1;
}

.stat-label {
  font-size: 14px;
  color: #6b7280;
  margin-bottom: 8px;
  font-weight: 500;
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 8px;
  line-height: 1;
}

.stat-change {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 600;
}

.change-up {
  color: #10b981;
}

.change-down {
  color: #ef4444;
}

.change-text {
  color: #6b7280;
  font-weight: 400;
  margin-left: 4px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  background: rgba(0, 0, 0, 0.03);
}

.stat-icon i {
  font-size: 28px;
  color: #6b7280;
}

/* Background Variants */
.bg-cream {
  background: #fef6ee;
}

.bg-cream .stat-icon {
  background: rgba(251, 146, 60, 0.1);
}

.bg-cream .stat-icon i {
  color: #fb923c;
}

.bg-green {
  background: #f0fdf4;
}

.bg-green .stat-icon {
  background: rgba(34, 197, 94, 0.1);
}

.bg-green .stat-icon i {
  color: #22c55e;
}

.bg-blue {
  background: #eff6ff;
}

.bg-blue .stat-icon {
  background: rgba(59, 130, 246, 0.1);
}

.bg-blue .stat-icon i {
  color: #3b82f6;
}

.bg-purple {
  background: #faf5ff;
}

.bg-purple .stat-icon {
  background: rgba(168, 85, 247, 0.1);
}

.bg-purple .stat-icon i {
  color: #a855f7;
}

.bg-red {
  background: #fef2f2;
}

.bg-red .stat-icon {
  background: rgba(239, 68, 68, 0.1);
}

.bg-red .stat-icon i {
  color: #ef4444;
}
</style>
