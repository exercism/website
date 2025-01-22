import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'

type GameStatus = 'running' | 'won' | 'lost'
type AlienStatus = 'alive' | 'dead'
class Alien {
  public status: AlienStatus

  public constructor(
    public elem: HTMLElement,
    row: number,
    col: number,
    type: number
  ) {
    this.status = 'alive'
  }
}
export default class DigitalClockExercise extends Exercise {
  private displayedTime?: String

  public constructor() {
    super('digital-clock')

    const time = new Date()
    this.hours = time.getHours()
    this.minutes = time.getMinutes()

    this.timeElem = document.createElement('div')
    this.timeElem.classList.add('time')
    this.view.appendChild(this.timeElem)

    this.hourElem = document.createElement('div')
    this.hourElem.classList.add('hour')
    this.timeElem.appendChild(this.hourElem)

    this.h1Elem = document.createElement('div')
    this.h1Elem.classList.add('h1')
    this.hourElem.appendChild(this.h1Elem)

    this.h2Elem = document.createElement('div')
    this.h2Elem.classList.add('h2')
    this.hourElem.appendChild(this.h2Elem)

    this.colonElem = document.createElement('div')
    this.colonElem.classList.add('colon')
    this.colonElem.innerText = ':'
    this.timeElem.appendChild(this.colonElem)

    this.minuteElem = document.createElement('div')
    this.minuteElem.classList.add('minute')
    this.timeElem.appendChild(this.minuteElem)

    this.m1Elem = document.createElement('div')
    this.m1Elem.classList.add('m1')
    this.minuteElem.appendChild(this.m1Elem)

    this.m2Elem = document.createElement('div')
    this.m2Elem.classList.add('m2')
    this.minuteElem.appendChild(this.m2Elem)

    this.meridiem = document.createElement('div')
    this.meridiem.classList.add('meridiem')
    this.view.appendChild(this.meridiem)
  }

  public getState() {
    return { displayedTime: this.displayedTime }
  }

  public setTime(hours: number, minutes: number) {
    this.hours = hours
    this.minutes = minutes
  }

  public didDisplayCurrentTime(executionCtx: ExecutionContext) {
    if (this.displayedTime === undefined) {
      return false
    }

    const ampm = this.hours >= 12 ? 'pm' : 'am'
    const normalisedHours = this.hours > 12 ? this.hours - 12 : this.hours

    return this.displayedTime == `${normalisedHours}:${this.minutes}${ampm}`
  }

  public currentTimeHour(_: ExecutionContext): number {
    return this.hours
  }
  public currentTimeMinute(_: ExecutionContext): number {
    return this.minutes
  }

  public displayTime(
    executionCtx: ExecutionContext,
    hours: string,
    mins: string,
    ampm: string
  ) {
    this.displayedTime = `${hours}:${mins}${ampm}`

    const [h1, h2] = String(hours).padStart(2, '0').split('')
    const [m1, m2] = String(mins).padStart(2, '0').split('')

    this.h1Elem.innerText = h1
    this.h2Elem.innerText = h2
    this.m1Elem.innerText = m1
    this.m2Elem.innerText = m2

    if (ampm === 'am' || ampm === 'pm') {
      this.meridiem.innerText = ampm
      this.meridiem.classList.add(ampm)
    }
  }

  public availableFunctions = [
    {
      name: 'current_time_hour',
      func: this.currentTimeHour.bind(this),
      description: 'Returns the current hour',
    },
    {
      name: 'current_time_minute',
      func: this.currentTimeMinute.bind(this),
      description: 'Returns the current minute',
    },
    {
      name: 'display_time',
      func: this.displayTime.bind(this),
      description: 'Writes the hour, minute and am/pm onto the digital display',
    },
  ]
}
