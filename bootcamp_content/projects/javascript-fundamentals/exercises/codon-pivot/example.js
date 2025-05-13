function codonsToProteins(codons) {
  const map = {
    AUG: 'Methionine',
    UUU: 'Phenylalanine',
    UUC: 'Phenylalanine',
    UUA: 'Leucine',
    UUG: 'Leucine',
    UCU: 'Serine',
    UCC: 'Serine',
    UCA: 'Serine',
    UCG: 'Serine',
    UAU: 'Tyrosine',
    UAC: 'Tyrosine',
    UGU: 'Cysteine',
    UGC: 'Cysteine',
    UGG: 'Tryptophan',
    UAA: 'STOP',
    UAG: 'STOP',
    UGA: 'STOP',
  }

  const proteins = []
  for (const codon of codons) {
    const protein = map[codon]
    if (protein === 'STOP') break
    proteins.push(protein)
  }
  return proteins
}

function rnaToCodons(rna) {
  const codons = []
  for (let i = 0; i < rna.length; i += 3) {
    const codon = rna.slice(i, i + 3)
    if (codon) codons.push(codon)
  }
  return codons
}

export function translateRna(rna) {
  return codonsToProteins(rnaToCodons(rna))
}
