import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { InterpretResult } from '@/interpreter/interpreter'
import { AnimeCSSProperties } from '../../AnimationTimeline/types'

type state = 'absent' | 'present' | 'correct' | 'correct'

export default class WordleExercise extends Exercise {
  private STATE_COLORS: Record<state, string> = {
    absent: 'rgb(120, 124, 126)',
    present: 'rgb(201, 180, 88)',
    correct: 'rgb(106, 170, 100)',
  }
  private guessRows: HTMLElement[] = []
  private states: state[][] = []

  public getState() {
    return {}
  }

  public constructor() {
    super('wordle')
    this.setupView()
  }

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

  public drawGuesses(executionCtx: ExecutionContext, guesses: string[]) {
    guesses.forEach((guess, idx) => {
      this.drawGuess(executionCtx, idx, guess)
    })
  }

  // Updates the board with the guess
  private drawGuess(
    executionCtx: ExecutionContext,
    idx: number,
    guess: string
  ) {
    const row = this.guessRows[idx]
    const letters = row.getElementsByClassName('letter')

    // Compare input with the target word
    ;[...guess].forEach((char, i) => {
      const letter = letters[i] as HTMLElement
      letter.textContent = char.toLowerCase()
    })
  }

  private createGuessRow() {
    const row = document.createElement('div')
    row.classList.add('guess')

    const randomId = `letter-${Math.random().toString(36).substr(2, 9)}`
    row.innerHTML = `
      <div class="letter" id="${randomId}_0" style="background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_1" style="background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_2" style="background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_3" style="background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_4" style="background-color:rgba(255,255,255)"></div>
    `
    return row
  }
  public statesForRow(_: InterpretResult, rowIdx: number) {
    console.log(this.states[rowIdx])
    return this.states[rowIdx]
  }

  private colorTopRow(executionCtx: ExecutionContext, colors: Jiki.List) {
    this.colorRow(executionCtx, new Jiki.Number(1), colors)
  }

  private colorRow(
    executionCtx: ExecutionContext,
    rowIdx: Jiki.Number,
    states: Jiki.List
  ) {
    const row = this.guessRows[rowIdx.value - 1]
    this.states[rowIdx.value - 1] = Jiki.unwrapJikiObject(states) as state[]

    const letters = row.getElementsByClassName('letter')
    states.value.forEach((color: Jiki.JikiObject, idx: number) => {
      if (!(color instanceof Jiki.String)) {
        return executionCtx.logicError('Color must be a string')
      }
      const backgroundColor: string = this.STATE_COLORS[color.value]
      if (!backgroundColor) {
        return executionCtx.logicError('Invalid state')
      }
      console.log(backgroundColor)
      const letter = letters[idx] as HTMLElement
      this.addAnimation({
        targets: `#${letter.id}`,
        duration: 10,
        transformations: {
          backgroundColor,
          color: 'rgb(255,255,255)',
        },
        offset: executionCtx.getCurrentTime(),
      })
    })
  }

  public availableFunctions = [
    {
      name: 'color_row',
      func: this.colorRow.bind(this),
      description: 'colored the squares in the row',
    },
    {
      name: 'color_top_row',
      func: this.colorTopRow.bind(this),
      description: 'colored the squares in the top row',
    },
  ]
}
