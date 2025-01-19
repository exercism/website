import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'

export default class WordleExercise extends Exercise {
  private targetWord = 'apple'
  private currentGuessIdx = 0
  private guessRows: HTMLElement[] = []
  private guessStates: string[][] = []

  public getState() {
    return {}
  }

  public getGuessState1() {
    return this.guessStates[0]
  }

  public constructor() {
    super('wordle')
    this.setupView()

    this.handleGuess('emote')
    this.handleGuess('prime')
    this.handleGuess('apese')
  }

  private handleGuess(guess: string) {
    // Ensure input is a 5-character string
    if (guess.length !== 5) {
      console.error('Input must be exactly 5 characters.')
      return
    }

    const guessArray = guess.split('')
    const states = this.statesFromGuess(guessArray)
    this.drawGuess(guessArray, states)
  }

  private statesFromGuess(guess: string[]) {
    const states = []
    for (let i = 0; i < guess.length; i++) {
      const char = guess[i].toLowerCase()

      if (char === this.targetWord[i]) {
        states.push('correct')
      } else if (this.targetWord.includes(char)) {
        states.push('present')
      } else {
        states.push('absent')
      }
    }
    return states
  }

  // Updates the board with the guess
  private drawGuess(guess: string[], states: string[]) {
    // Get the current row
    if (this.currentGuessIdx >= this.guessRows.length) {
      console.error('No more guesses allowed.')
      return
    }

    const row = this.guessRows[this.currentGuessIdx]
    const letters = row.getElementsByClassName('letter')

    const guessLetterStates = []
    // Compare input with the target word
    guess.forEach((char, i) => {
      const letter = letters[i] as HTMLElement
      letter.textContent = char.toLowerCase()
      letter.dataset.state = states[i]
      guessLetterStates.push(states[i])
    })

    // Store the states for checking later
    this.guessStates.push(guessLetterStates)

    // Move to the next row
    this.currentGuessIdx++
  }

  public availableFunctions = []

  private setupView() {
    this.container = document.createElement('div')
    this.container.classList.add('container')
    this.view.appendChild(this.container)

    const board = document.createElement('div')
    board.classList.add('board')
    this.container.appendChild(board)

    for (let i = 0; i < 6; i++) {
      this.guessRows.push(this.createGuessRow())
    }

    this.guessRows.forEach((row) => {
      board.appendChild(row)
    })
  }

  private createGuessRow() {
    const row = document.createElement('div')
    row.classList.add('guess')
    row.innerHTML = `
      <div class="letter"></div>
      <div class="letter"></div>
      <div class="letter"></div>
      <div class="letter"></div>
      <div class="letter"></div>
    `
    return row
  }
}
