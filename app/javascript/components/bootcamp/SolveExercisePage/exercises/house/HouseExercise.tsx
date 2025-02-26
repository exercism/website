import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { InterpretResult } from '@/interpreter/interpreter'
import DrawExercise from '../draw'
import { buildRoof } from './Roof'
import { buildFrame } from './Frame'
import { buildWindow } from './Window'
import { buildDoor } from './Door'
import { buildGround } from './Ground'
import { buildSky } from './Sky'
import { buildSun } from './Sun'

export default class HouseExercise extends DrawExercise {
  private Roof = buildRoof(this)
  private Frame = buildFrame(this)
  private Window = buildWindow(this)
  private Door = buildDoor(this)
  private Ground = buildGround(this)
  private Sky = buildSky(this)
  private Sun = buildSun(this)

  protected events: string[] = []

  public constructor() {
    super('house')

    this.container = document.createElement('div')
    this.container.classList.add('container')
    this.view.appendChild(this.container)
  }

  public getState() {
    return {}
  }

  public getFalse() {
    return false
  }

  public checkSunSet() {
    return this.events.includes('sun:position:-4,90')
  }

  public checkLightsOn() {
    return (
      this.events.filter((event) => event.includes('window:lights:on'))
        .length == 2
    )
  }

  public checkSunBeforeLights() {
    const sunsetIdx = this.events.indexOf('sun:position:-4,90')
    const lightsOnIdx = this.events.indexOf('window:lights:on')

    return sunsetIdx < lightsOnIdx
  }

  public checkLightsBeforeBrightness() {
    const lightsOnIdx = this.events.indexOf('window:lights:on')
    const roofBrightnessIdx = this.events.indexOf('roof:brightness:99')

    return lightsOnIdx < roofBrightnessIdx
  }
  public skyReachedHue192() {
    return this.events.includes('sky:hue:192')
  }
  public skyReachedHue310() {
    return this.events.includes('sky:hue:310')
  }
  public elementsReachedBrightness80() {
    return (
      this.events.includes('roof:brightness:80') &&
      this.events.includes('roof:brightness:80') &&
      this.events.includes('frame:brightness:80') &&
      this.events.includes('door:brightness:80') &&
      this.events.includes('ground:brightness:80') &&
      this.events.includes('sky:brightness:80')
    )
  }
  public elementsReachedBrightness20() {
    return (
      this.events.includes('roof:brightness:20') &&
      this.events.includes('roof:brightness:20') &&
      this.events.includes('frame:brightness:20') &&
      this.events.includes('door:brightness:20') &&
      this.events.includes('ground:brightness:20') &&
      this.events.includes('sky:brightness:20')
    )
  }
  public elementsReachedBrightness19() {
    return !(
      this.events.includes('roof:brightness:19') ||
      this.events.includes('roof:brightness:19') ||
      this.events.includes('frame:brightness:19') ||
      this.events.includes('door:brightness:19') ||
      this.events.includes('ground:brightness:19') ||
      this.events.includes('sky:brightness:19')
    )
  }

  // Setup Functions
  public setupBlocks(_: ExecutionContext, layout: [][]) {}

  public availableClasses = [
    this.Roof,
    this.Frame,
    this.Window,
    this.Door,
    this.Ground,
    this.Sky,
    this.Sun,
  ]

  public availableFunctions = []
}
