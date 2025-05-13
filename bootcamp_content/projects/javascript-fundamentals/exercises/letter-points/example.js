function letterValues() {
  const values = [
    ['AEIOULNRST', 1],
    ['DG', 2],
    ['BCMP', 3],
    ['FHVWY', 4],
    ['K', 5],
    ['JX', 8],
    ['QZ', 10],
  ]

  const dict = {}
  for (const [letters, value] of values) {
    for (const letter of letters) {
      dict[letter] = value
    }
  }
  return dict
}

export function letterPoints(word) {
  const scores = letterValues()
  let score = 0
  for (const letter of word) {
    score += scores[letter.toUpperCase()] || 0
  }
  return score
}
