/**
 * The day rate, given a rate per hour
 *
 * @param {number} ratePerHour
 * @returns {number} the rate per day
 */
export function dayRate(ratePerHour) {
  return ratePerHour * 8
}

/**
 * Calculates the number of days in a budget, rounded down
 *
 * @param {number} budget the total budget
 * @param {number} ratePerHour the rate per hour
 * @returns {number} the number of days
 */
export function daysInBudget(budget, ratePerHour) {
  return Math.floor(budget / dayRate(ratePerHour))
}

/**
 * Calculates the discounted rate for large projects, rounded up
 *
 * @param {number} ratePerHour
 * @param {number} numDays: number of days the project spans
 * @param {number} discount: for example 20% written as 0.2
 * @returns {number} the discounted rate, rounded up
 */
export function priceWithMonthlyDiscount(ratePerHour, numDays, discount) {
  const billableDaysPerMonth = 22
  const numMonths = Math.floor(numDays / billableDaysPerMonth)
  const monthlyRate = billableDaysPerMonth * dayRate(ratePerHour)
  const monthlyDiscountedRate = (1 - discount) * monthlyRate

  const numExtraDays = numDays % billableDaysPerMonth
  const priceExtraDays = numExtraDays * dayRate(ratePerHour)

  return Math.ceil(numMonths * monthlyDiscountedRate + priceExtraDays)
}
