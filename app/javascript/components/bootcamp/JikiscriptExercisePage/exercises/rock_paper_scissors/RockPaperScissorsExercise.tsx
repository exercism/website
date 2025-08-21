import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'

type Choice = 'rock' | 'paper' | 'scissors'
type Result = 'player_1' | 'player_2' | 'tie'

export default class RockPaperScissorsExercise extends Exercise {
  private player1Choice?: Choice
  private player2Choice?: Choice
  private expectedResult?: Result
  private result?: Result

  public constructor() {
    super('rock-paper-scissors')

    this.container = document.createElement('div')
    this.container.classList.add('container')
    this.view.appendChild(this.container)

    this.player1Elem = document.createElement('div')
    this.player1Elem.classList.add('player', 'player-1')
    this.container.appendChild(this.player1Elem)

    this.player2Elem = document.createElement('div')
    this.player2Elem.classList.add('player', 'player-2')
    this.container.appendChild(this.player2Elem)
  }

  public getState() {
    return { result: this.result }
  }

  public setChoices(_: ExecutionContext, player1: Choice, player2: Choice) {
    this.player1Choice = player1
    this.player2Choice = player2
    this.expectedResult = this.determineCorrectResult()

    this.player1Elem.classList.add(`${player1}`)
    this.player2Elem.classList.add(`${player2}`)
    this.view.classList.add(`result-${this.expectedResult}`)
  }

  private determineCorrectResult(): Result | undefined {
    if (!this.player1Choice || !this.player2Choice) {
      return undefined
    }

    if (this.player1Choice === this.player2Choice) {
      return 'tie'
    }
    if (this.player1Choice === 'rock' && this.player2Choice === 'scissors') {
      return 'player_1'
    }
    if (this.player1Choice === 'scissors' && this.player2Choice === 'paper') {
      return 'player_1'
    }
    if (this.player1Choice === 'paper' && this.player2Choice === 'rock') {
      return 'player_1'
    }

    return 'player_2'
  }

  public getPlayer1Choice(_: ExecutionContext): Jiki.String {
    return new Jiki.String(this.player1Choice!)
  }

  public getPlayer2Choice(_: ExecutionContext): Jiki.String {
    return new Jiki.String(this.player2Choice!)
  }

  public announceResult(executionCtx: ExecutionContext, result: Jiki.String) {
    const resultStr = result.value
    if (
      resultStr !== 'player_1' &&
      resultStr !== 'player_2' &&
      resultStr !== 'tie'
    ) {
      executionCtx.logicError(
        'Oh no! You announced an invalid result. There\'s chaos in the playing hall! Please announce either "player_1", "player_2" or "tie".'
      )
    }

    this.result = resultStr
    if (resultStr !== this.expectedResult) {
      // TODO: Change logic error to be paramatized and sanitize the strings in the interpreter.
      executionCtx.logicError(
        `Oh no! You announced the wrong result. There's chaos in the playing hall!\n\nYou should have announced \`"${this.expectedResult}"\` but you announced \`"${result}"\`.`
      )
    }
  }

  public availableFunctions = [
    {
      name: 'announce_result',
      func: this.announceResult.bind(this),
      description: 'announced the result of the game as ${arg1}',
    },
    {
      name: 'get_player_1_choice',
      func: this.getPlayer1Choice.bind(this),
      description: 'returned the choice of player 1',
    },
    {
      name: 'get_player_2_choice',
      func: this.getPlayer2Choice.bind(this),
      description: 'returned the choice of player 2',
    },
  ]
}
