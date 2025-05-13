function transformStrand(strand) {
  const dna = ['A', 'C', 'G', 'T']
  const rna = ['U', 'G', 'C', 'A']

  const index = dna.indexOf(strand)
  return index !== -1 ? rna[index] : undefined
}

export function dnaToRna(dna) {
  return [...dna].map(transformStrand).join('')
}
