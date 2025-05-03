function isLetter(letter) {
  return letter.toLowerCase() != letter.toUpperCase()
}

export function acronym(sentence) {
  let output = ''
  let was_space = true

  for (const letter of sentence) {
    if (letter == ' ' || letter == '-') {
      was_space = true
    } else if (was_space && isLetter(letter)) {
      output += letter
      was_space = false
    }
  }

  return output.toUpperCase()
}
