function isLetter(letter) {
  return letter.toLowerCase() != letter.toUpperCase()
}

export function acronym(sentence) {
  let output = ''
  let wasSpace = true

  for (const letter of sentence) {
    if (letter == ' ' || letter == '-') {
      wasSpace = true
    } else if (wasSpace && isLetter(letter)) {
      output += letter
      wasSpace = false
    }
  }

  return output.toUpperCase()
}
