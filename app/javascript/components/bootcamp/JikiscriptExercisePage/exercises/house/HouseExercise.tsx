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
import { buildRectangle } from './Rectangle'
import { buildCircle } from './Circle'
import { buildTriangle } from './Triangle'
import { buildHSLColor } from './HSLColor'

export default class HouseExercise extends DrawExercise {
  private Roof = buildRoof(this)
  private Frame = buildFrame(this)
  private Window = buildWindow(this)
  private Door = buildDoor(this)
  private Ground = buildGround(this)
  private Sky = buildSky(this)
  private Sun = buildSun(this)
  private Rectangle = buildRectangle(this)
  private Circle = buildCircle(this)
  private Triangle = buildTriangle(this)
  private HSLColor = buildHSLColor(this)

  public events: string[] = []

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
    return (
      this.events.includes('sun:position:-4,90') ||
      this.events.includes('circle:position:-4,90')
    )
  }

  public checkLightsOn() {
    return (
      this.events.filter((event) => event.includes('window:lights:on'))
        .length == 2 ||
      this.events.filter((event) => event.includes('rectangle:hsl:56:100:50'))
        .length == 2
    )
  }

  public checkSunBeforeLights() {
    let sunsetIdx = this.events.indexOf('sun:position:-4,90')
    if (sunsetIdx == -1)
      sunsetIdx = this.events.indexOf('circle:position:-4,90')
    let lightsOnIdx = this.events.indexOf('window:lights:on')
    if (lightsOnIdx == -1)
      lightsOnIdx = this.events.indexOf('rectangle:hsl:56:100:50')

    return sunsetIdx < lightsOnIdx
  }

  public checkLightsBeforeBrightness() {
    let lightsOnIdx = this.events.indexOf('window:lights:on')
    if (lightsOnIdx == -1)
      lightsOnIdx = this.events.indexOf('rectangle:hsl:56:100:50')

    let roofBrightnessIdx = this.events.indexOf('roof:brightness:99')
    if (roofBrightnessIdx == -1)
      roofBrightnessIdx = this.events.indexOf('triangle:brightness:99')

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
      (this.events.includes('roof:brightness:80') &&
        this.events.includes('frame:brightness:80') &&
        this.events.includes('door:brightness:80') &&
        this.events.includes('ground:brightness:80') &&
        this.events.includes('sky:brightness:80')) ||
      (this.events.includes('triangle:brightness:80') &&
        this.events.includes('rectangle:brightness:80') &&
        this.events.includes('circle:brightness:80'))
    )
  }
  public elementsReachedBrightness20() {
    return (
      (this.events.includes('roof:brightness:20') &&
        this.events.includes('roof:brightness:20') &&
        this.events.includes('frame:brightness:20') &&
        this.events.includes('door:brightness:20') &&
        this.events.includes('ground:brightness:20') &&
        this.events.includes('sky:brightness:20')) ||
      (this.events.includes('triangle:brightness:20') &&
        this.events.includes('rectangle:brightness:20') &&
        this.events.includes('circle:brightness:20'))
    )
  }
  public elementsReachedBrightness19() {
    return (
      !(
        this.events.includes('roof:brightness:19') ||
        this.events.includes('roof:brightness:19') ||
        this.events.includes('frame:brightness:19') ||
        this.events.includes('door:brightness:19') ||
        this.events.includes('ground:brightness:19') ||
        this.events.includes('sky:brightness:19')
      ) ||
      (this.events.includes('triangle:brightness:19') &&
        this.events.includes('rectangle:brightness:19') &&
        this.events.includes('circle:brightness:19'))
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
    this.Rectangle,
    this.Circle,
    this.Triangle,
    this.HSLColor,
  ]

  public availableFunctions = []
}
