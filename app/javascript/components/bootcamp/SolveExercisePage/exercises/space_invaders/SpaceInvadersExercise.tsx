import React from 'react'
import { Exercise } from '../Exercise'

export default class SpaceInvadersExercise extends Exercise {
  public getState() {
    return {}
  }

  public constructor() {
    super('space-invaders')
  }

  public runGame(_: any) {
    console.log('running game')
  }

  public availableFunctions = [
    {
      name: 'runGame',
      func: this.runGame,
      description: '',
    },
  ]
}
