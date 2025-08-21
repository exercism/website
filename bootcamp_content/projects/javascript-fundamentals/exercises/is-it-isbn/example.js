export function isValidIsbn(isbn) {
  let total = 0
  let multiplier = 10

  for (const char of isbn) {
    let num

    if (char === 'X' && multiplier === 1) {
      num = 10
    } else if (char === '-') {
      continue
    } else if ('0123456789'.includes(char)) {
      num = Number(char)
    } else {
      return false
    }

    total += num * multiplier
    multiplier--
  }

  if (multiplier !== 0) {
    return false
  }

  return total % 11 === 0
}
