const words = getCommonWords()
const targetWord = getTargetWord()

function addOrIncrement(things, thing) {
  if (!(thing in things)) things[thing] = 0
  things[thing] += 1
  return things
}

function letterOkInGuess(letter, knowledge, letterKnowledge) {
  if (letterKnowledge.actual !== '') {
    return letter === letterKnowledge.actual
  }
  if (knowledge.absent.includes(letter)) {
    return false
  }
  if (letterKnowledge.not.includes(letter)) {
    return false
  }
  return true
}

function unique(list) {
  return [...new Set(list)]
}

function isWordPossible(word, knowledge) {
  for (let idx = 0; idx < word.length; idx++) {
    const letter = word[idx]
    if (!letterOkInGuess(letter, knowledge, knowledge.squares[idx])) {
      return false
    }
  }
  for (const letter of knowledge.present) {
    if (!word.includes(letter)) {
      return false
    }
  }
  return true
}

function chooseWord(knowledge) {
  return words.find((word) => isWordPossible(word, knowledge))
}

function setupKnowledge() {
  return {
    present: [],
    absent: [],
    squares: Array.from({ length: 5 }, () => ({ actual: '', not: [] })),
    won: false,
  }
}

function hasWon(states) {
  return states.every((state) => state === 'correct')
}

function shouldBePresent(presentLetters, targetWord, letter) {
  if (!(letter in presentLetters)) return true

  const actual = [...targetWord].filter((c) => c === letter).length
  return actual > presentLetters[letter]
}

function processGuess(knowledge, row, guess) {
  const states = []
  let presentLetters = {}

  for (let idx = 0; idx < guess.length; idx++) {
    const letter = guess[idx]
    if (targetWord[idx] === letter) {
      knowledge.squares[idx].actual = letter
      presentLetters = addOrIncrement(presentLetters, letter)
      states.push('correct')
    } else if (targetWord.includes(letter)) {
      knowledge.present = unique([...knowledge.present, letter])
      knowledge.squares[idx].not.push(letter)
      states.push('present')
    } else {
      knowledge.absent = unique([...knowledge.absent, letter])
      states.push('absent')
    }
  }

  for (let idx = 0; idx < guess.length; idx++) {
    const letter = guess[idx]
    if (states[idx] !== 'present') continue

    if (shouldBePresent(presentLetters, targetWord, letter)) {
      presentLetters = addOrIncrement(presentLetters, letter)
    } else {
      states[idx] = 'absent'
    }
  }

  knowledge.won = hasWon(states)
  addWord(row, guess, states)
  return knowledge
}

export function playGame() {
  let knowledge = setupKnowledge()
  for (let idx = 0; idx < 6; idx++) {
    knowledge = processGuess(knowledge, idx, chooseWord(knowledge))
    if (knowledge.won) break
  }
}
