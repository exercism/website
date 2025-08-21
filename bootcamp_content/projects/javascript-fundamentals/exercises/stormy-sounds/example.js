export function stormySounds(num) {
  let str = ''

  if (num % 3 === 0) str += 'Pling'
  if (num % 5 === 0) str += 'Plang'
  if (num % 7 === 0) str += 'Plong'

  return str || num.toString()
}
