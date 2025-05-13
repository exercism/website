export function countNucleotides(dna) {
  const counts = { A: 0, C: 0, G: 0, T: 0 }
  const strandTypes = Object.keys(counts)

  for (const strand of dna) {
    if (!strandTypes.includes(strand)) {
      return false
    }
    counts[strand]++
  }

  return counts
}
