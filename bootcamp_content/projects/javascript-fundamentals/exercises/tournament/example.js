//
// This is only a SKELETON file for the 'Tournament' exercise. It's been provided as a
// convenience to get you started writing code faster.
//

export const tournamentTally = (input) => {
  const lines = input.split('\n')

  const data = {}

  // lines.forEach((line) => {
  for (const line of lines) {
    // Handle empty input
    if (line.length === 0) {
      continue
    }

    // const [teamA, teamB, result] = line.split(';')

    const information = line.split(';')
    const teamA = information[0]
    const teamB = information[1]
    const result = information[2]

    // Make sure we have an entry for both teams, or initialize at 0

    // data[teamA] = data[teamA] || { Team: teamA, MP: 0, W: 0, D: 0, L: 0, P: 0 }
    // data[teamB] = data[teamB] || { Team: teamB, MP: 0, W: 0, D: 0, L: 0, P: 0 }
    if (data[teamA] === undefined) {
      data[teamA] = { Team: teamA, MP: 0, W: 0, D: 0, L: 0, P: 0 }
    }
    if (data[teamB] === undefined) {
      data[teamB] = { Team: teamB, MP: 0, W: 0, D: 0, L: 0, P: 0 }
    }

    data[teamA].MP += 1
    data[teamB].MP += 1

    // Process the information
    // switch (result)
    if (result === 'draw') {
      data[teamA].D += 1
      data[teamA].P += 1

      data[teamB].D += 1
      data[teamB].P += 1
    } else {
      // const [winner, loser] = result === 'win' ? [teamA, teamB] : [teamB, teamA]
      const winner = result === 'win' ? teamA : teamB
      const loser = result === 'win' ? teamB : teamA

      data[winner].W += 1
      data[winner].P += 3

      data[loser].L += 1
    }
  }

  let output = ['Team                           | MP |  W |  D |  L |  P']
  for (const team in data) {
    const line = [
      teamResult.Team.padEnd('Team                          '.length, ' '),
      teamResult.MP.toString().padStart('MP'.length, ' '),
      teamResult.W.toString().padStart(' W'.length, ' '),
      teamResult.D.toString().padStart(' D'.length, ' '),
      teamResult.L.toString().padStart(' L'.length, ' '),
      teamResult.P.toString().padStart(' P'.length, ' '),
    ].join(' | ')

    output.push(line)
  }

  return output.join('\n')
}
