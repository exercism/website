import React from 'react'
import type { ExecutionContext, ExternalFunction } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { buildRobot } from './Robot'

export default class ChattyRobotsExercise extends Exercise {
  private Robot = buildRobot(this)

  public static hasView = false
  public interactions: string[] = []

  public constructor() {
    super()
  }

  public getState() {
    return {}
  }

  public availableClasses: Jiki.Class[] = [this.Robot]
  public availableFunctions: ExternalFunction[] = []
}
