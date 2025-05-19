import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { InterpretResult } from '@/interpreter/interpreter'
import { AnimeCSSProperties } from '../../AnimationTimeline/types'
import { buildWordleGame } from './WordleGame'
import { utils } from '@juliangarnierorg/anime-beta'

type state = 'absent' | 'present' | 'correct' | 'correct'

export default class WordleExercise extends Exercise {
  private WordleGame = buildWordleGame(this)
  public targetWord: string = ''

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
  }

  public setTargetWord(_: ExecutionContext, word: string) {
    this.targetWord = word
  }
  private getTargetWord(_: ExecutionContext) {
    return this.targetWord
  }

  public createGame(executionCtx: ExecutionContext) {
    this.game = this.WordleGame.instantiate(executionCtx, [])
    this.game.getMethod('draw_board').fn.call(this.game, executionCtx)
  }

  private addWord(executionCtx: ExecutionContext, row, guess, states) {
    if (row == undefined || row == null) {
      executionCtx.logicError(
        'Row is undefined or null. Please provide a valid row number.'
      )
    }
    if (guess == undefined || guess == null) {
      executionCtx.logicError(
        'The word is undefined or null. Please provide a string.'
      )
    }
    if (states == undefined || states == null) {
      executionCtx.logicError(
        'The states array is undefined or null. Please provide a valid array.'
      )
    }

    this.game
      .getMethod('add_word')
      .fn.call(
        this.game,
        executionCtx,
        executionCtx,
        Jiki.wrapJSToJikiObject(row + 1),
        Jiki.wrapJSToJikiObject(guess),
        Jiki.wrapJSToJikiObject(states)
      )
  }

  public setupView(_: ExecutionContext) {
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

  public drawGuesses(_: ExecutionContext, guesses: string[]) {
    guesses.forEach((guess, idx) => {
      this.drawGuess(null, idx, guess)
    })
  }

  // Updates the board with the guess
  public drawGuess(
    executionCtx: ExecutionContext | null,
    idx: number,
    guess: string
  ) {
    if (
      this.guessRows.length === 0 ||
      this.guessRows[0].children.length === 0
    ) {
      executionCtx?.logicError(
        'Ooops! You need to draw the board before you can add words.'
      )
    }
    const row = this.guessRows[idx]
    const letters = row.getElementsByClassName('letter')

    // Compare input with the target word
    ;[...guess].forEach((char, i) => {
      const letter = letters[i] as HTMLElement
      letter.innerHTML = '&nbsp;'
      letter.textContent = char.toLowerCase()

      this.addAnimation({
        targets: `#${letter.id}`,
        duration: 1,
        transformations: {
          color: 'rgba(255,255,255,1)',
        },
        offset: executionCtx?.getCurrentTime() || 0,
      })
    })
    executionCtx?.fastForward(1)
  }

  private createGuessRow() {
    const row = document.createElement('div')
    row.classList.add('guess')

    const randomId = `letter-${Math.random().toString(36).substr(2, 9)}`
    row.innerHTML = `
      <div class="letter" id="${randomId}_0" style="color:rgba(255,255,255,0);background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_1" style="color:rgba(255,255,255,0);background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_2" style="color:rgba(255,255,255,0);background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_3" style="color:rgba(255,255,255,0);background-color:rgba(255,255,255)"></div>
      <div class="letter" id="${randomId}_4" style="color:rgba(255,255,255,0);background-color:rgba(255,255,255)"></div>
    `
    return row
  }
  public statesForRow(_: InterpretResult, rowIdx: number) {
    return this.states[rowIdx]
  }

  private colorTopRow(executionCtx: ExecutionContext, states: Jiki.JikiObject) {
    if (!(states instanceof Jiki.List)) {
      return executionCtx.logicError('Oops, the input must be a list.')
    }

    this.colorRow(executionCtx, new Jiki.Number(1), states)
  }

  public colorRow(
    executionCtx: ExecutionContext,
    rowIdx: Jiki.JikiObject,
    states: Jiki.JikiObject
  ) {
    if (!(rowIdx instanceof Jiki.Number)) {
      return executionCtx.logicError('Row must be a number')
    }
    if (rowIdx.value < 1 || rowIdx.value > 6) {
      return executionCtx.logicError('Row must be between 1 and 6')
    }
    if (!(states instanceof Jiki.List)) {
      return executionCtx.logicError('Oops, the second input must be a list.')
    }
    const row = this.guessRows[rowIdx.value - 1]
    this.states[rowIdx.value - 1] = Jiki.unwrapJikiObject(states) as state[]

    const letters = row.getElementsByClassName('letter')
    states.value.forEach((color: Jiki.JikiObject, idx: number) => {
      if (!(color instanceof Jiki.String)) {
        return executionCtx.logicError('Color must be a string')
      }
      if (idx > 4) {
        return executionCtx.logicError(
          'There are only 5 letters so there should only be 5 states for each guess.'
        )
      }
      const backgroundColor: string = this.STATE_COLORS[color.value]
      if (!backgroundColor) {
        return executionCtx.logicError('Invalid state')
      }
      const letter = letters[idx] as HTMLElement
      this.addAnimation({
        targets: `#${letter.id}`,
        duration: 1,
        transformations: {
          backgroundColor,
          color: 'rgb(255,255,255)',
        },
        offset: executionCtx.getCurrentTime(),
      })
    })
    executionCtx.fastForward(1)
  }

  private commonWords = [
    'which',
    'about',
    'there',
    'their',
    'would',
    'these',
    'other',
    'words',
    'colly',
    'could',
    'write',
    'first',
    'water',
    'after',
    'where',
    'right',
    'think',
    'three',
    'years',
    'place',
    'sound',
    'great',
    'again',
    'still',
    'every',
    'small',
    'found',
    'those',
    'never',
    'under',
    'might',
    'while',
    'house',
    'world',
    'below',
    'asked',
    'going',
    'large',
    'until',
    'along',
    'shall',
    'being',
    'often',
    'earth',
    'began',
    'since',
    'study',
    'night',
    'light',
    'above',
    'paper',
    'parts',
    'young',
    'story',
    'point',
    'times',
    'heard',
    'whole',
    'white',
    'given',
    'means',
    'tonic',
    'music',
    'miles',
    'thing',
    'today',
    'later',
    'using',
    'money',
    'lines',
    'order',
    'group',
    'among',
    'learn',
    'known',
    'space',
    'table',
    'early',
    'trees',
    'short',
    'hands',
    'state',
    'black',
    'shown',
    'stood',
    'front',
    'voice',
    'kinds',
    'makes',
    'comes',
    'close',
    'power',
    'lived',
    'vowel',
    'taken',
    'built',
    'heart',
    'ready',
    'quite',
    'class',
    'woman',
    'women',
    'queen',
    'horse',
    'shows',
    'piece',
    'green',
    'stand',
    'birds',
    'start',
    'river',
    'tried',
    'least',
    'field',
    'whose',
    'girls',
    'leave',
    'added',
    'color',
    'third',
    'hours',
    'moved',
    'plant',
    'doing',
    'names',
    'forms',
    'heavy',
    'ideas',
    'cried',
    'check',
    'floor',
    'begin',
    'woman',
    'alone',
    'plane',
    'spell',
    'watch',
    'carry',
    'wrote',
    'clear',
    'named',
    'books',
    'child',
    'glass',
    'human',
    'takes',
    'party',
    'build',
    'seems',
    'blood',
    'sides',
    'seven',
    'mouth',
    'solve',
    'north',
    'value',
    'death',
    'maybe',
    'happy',
    'tells',
    'gives',
    'looks',
    'shape',
    'lives',
    'steps',
    'areas',
    'senes',
    'sense',
    'speak',
    'force',
    'ocean',
    'speed',
    'metal',
    'south',
    'grass',
    'scale',
    'cells',
    'clamp',
    'swabs',
    'wussy',
    'swift',
    'swine',
    'swiss',
    'swigs',
    'swims',
    'twice',

    'magic',
  ]
  private getCommonWords = (_: ExecutionContext) =>
    Jiki.wrapJSToJikiObject(this.commonWords)
  private getCommonWordsJS = (_: ExecutionContext) => [...this.commonWords]

  public availableClasses = [this.WordleGame]
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
    {
      name: 'common_words',
      func: this.getCommonWords.bind(this),
      description: 'returns the words in the game',
    },
    {
      name: 'getCommonWords',
      func: this.getCommonWordsJS.bind(this),
      description: 'returns the words in the game',
    },
    {
      name: 'addWord',
      func: this.addWord.bind(this),
      description: 'adds a word to the board',
    },
    {
      name: 'getTargetWord',
      func: this.getTargetWord.bind(this),
      description: 'returns the target word',
    },
  ]
}
