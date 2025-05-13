export function hammingDistance(str1, str2) {
  if (str1.length !== str2.length) {
    throw new Error('Strings must be of equal length')
  }

  let distance = 0
  for (let i = 0; i < str1.length; i++) {
    if (str1[i] !== str2[i]) {
      distance++
    }
  }
  return distance
}
