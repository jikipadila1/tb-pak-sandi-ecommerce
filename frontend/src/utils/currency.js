// Format number to Indonesian Rupiah
export const formatRupiah = (amount) => {
  if (!amount && amount !== 0) return 'Rp 0'

  const number = parseFloat(amount)
  if (isNaN(number)) return 'Rp 0'

  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0
  }).format(number)
}

// Parse Rupiah string to number
export const parseRupiah = (rupiahString) => {
  if (typeof rupiahString === 'number') return rupiahString
  return parseFloat(rupiahString.replace(/[Rp\s.]/g, '').replace(',', '.')) || 0
}
