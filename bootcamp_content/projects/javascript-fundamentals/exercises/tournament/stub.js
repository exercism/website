export function tournamentTally(data) {
  // Write your code here!
}

// We've provided you this function. You might be interested to
// explore how it works, but you don't need to understand it
// or change it. Read the instructions to see how to use it!
function sort(data, pointsKey, nameKey) {
  return data.sort((a, b) => {
    const pointsComparison = b[pointsKey] - a[pointsKey]
    if (pointsComparison != 0) {
      return pointsComparison
    }
    return a[nameKey].localeCompare(b[nameKey])
  })
}
