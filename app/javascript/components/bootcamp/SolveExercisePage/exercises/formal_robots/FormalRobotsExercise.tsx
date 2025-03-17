import React from 'react'
import type { ExecutionContext, ExternalFunction } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { buildRobot } from './Robot'
import { buildFormalConversation } from './FormalConversation'

export default class FormalRobotsExercise extends Exercise {
  private Robot = buildRobot(this)
  private FormalConversation = buildFormalConversation(this)

  public static hasView = false
  public interactions: string[] = []
  public robotNames: string[] = []
  public robotAges: number[] = []

  public constructor() {
    super()
  }

  public setRobotNames(_, robotNames: string[]) {
    this.robotNames = [...robotNames]
  }

  public setRobotAges(_, robotAges: number[]) {
    this.robotAges = [...robotAges]
  }

  public getState() {
    return {}
  }
  public getInteraction(_, idx: number) {
    return this.interactions[idx]
  }

  public availableClasses: Jiki.Class[] = [this.Robot, this.FormalConversation]
  public availableFunctions: ExternalFunction[] = []
}
