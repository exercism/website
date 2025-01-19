import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'

type Choice = 'rock' | 'paper' | 'scissors'
type Result = 'player_1' | 'player_2' | 'tie'

export default class RockPaperScissorsExercise extends Exercise {
  private player1Choice?: Choice
  private player2Choice?: Choice
  private result?: Result

  public constructor() {
    super('rock-paper-scissors')
  }

  public getState() {
    return { result: this.result }
  }

  public setChoices(player1: Choice, player2: Choice) {
    this.player1Choice = player1
    this.player2Choice = player2
  }

  private determineCorrectResult(): Result | null {
    if (!this.player1Choice || !this.player2Choice) {
      return null
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

  public getPlayer1Choice(_: ExecutionContext): Choice | undefined {
    return this.player1Choice
  }

  public getPlayer2Choice(_: ExecutionContext): Choice | undefined {
    return this.player2Choice
  }

  public announceResult(executionCtx: ExecutionContext, result: Result) {
    if (result !== 'player_1' && result !== 'player_2' && result !== 'tie') {
      executionCtx.logicError(
        'Oh no! You announced an invalid result. There\'s chaos in the playing hall! Please announce either "player1", "player2" or "tie".'
      )
    }

    const correctResult = this.determineCorrectResult()
    this.result = result
    if (result !== correctResult) {
      // TODO: Change logic error to be paramatized and sanitize the strings in the interpreter.
      executionCtx.logicError(
        `Oh no! You announced the wrong result. There's chaos in the playing hall!\n\nYou should have announced \`"${correctResult}"\` but you announced \`"${result}"\`.`
      )
    }
  }

  public availableFunctions = [
    {
      name: 'announce_result',
      func: this.announceResult.bind(this),
      description:
        'Announces the result of the game - a string of "player_1", "player_2" or "tie"',
    },
    {
      name: 'get_player_1_choice',
      func: this.getPlayer1Choice.bind(this),
      description: 'Returns the choice of player 1',
    },
    {
      name: 'get_player_2_choice',
      func: this.getPlayer2Choice.bind(this),
      description: 'Returns the choice of player 2',
    },
  ]
}
