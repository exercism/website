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
  public constructor() {
    super('digital-clock')

    const time = new Date()
    this.hours = time.getHours()
    this.minutes = time.getMinutes()

    this.timeElem = document.createElement('div')
    this.timeElem.classList.add('time')
    this.view.appendChild(this.timeElem)

    this.meridiem = document.createElement('div')
    this.meridiem.classList.add('meridiem')
    this.view.appendChild(this.meridiem)
  }

  public getState() {
    return {}
  }

  public displayedCurrentTime(executionCtx: ExecutionContext) {
    const ampm = this.hours >= 12 ? 'pm' : 'am'
    const normalisedHours = this.hours > 12 ? this.hours - 12 : this.hours
    return this.wasFunctionUsed(executionCtx, 'display_time', [
      this.formatTime(executionCtx, normalisedHours, this.minutes, ampm),
    ])
  }

  public setTime(hours: number, minutes: number) {
    this.hours = hours
    this.minutes = minutes
  }

  public currentTimeHour(_: ExecutionContext): number {
    return this.hours
  }

  public currentTimeMinute(_: ExecutionContext): number {
    return this.minutes
  }

  public formatTime(
    _: ExecutionContext,
    hours: string,
    mins: string,
    ampm: string
  ): string {
    return `${hours}:${String(mins).padStart(2, '0')} ${ampm}`
  }

  public displayTime(executionCtx: ExecutionContext, timeString: string) {
    this.recordFunctionUse('display_time', timeString)

    const timePattern = /^([0-9][0-9]?:[0-9]{2}) ([ap]m)$/
    const match = timeString.match(timePattern)

    if (!match) {
      executionCtx.logicError("The time string wasn't in a valid format")
      return
    }

    const [_, time, meridiem] = match

    this.timeElem.innerText = time
    this.meridiem.innerText = meridiem
    this.meridiem.classList.remove('am', 'pm')
    if (meridiem === 'am') {
      this.meridiem.classList.add('am')
    } else {
      this.meridiem.classList.add('pm')
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
      description: 'Writes the time on the clock',
    },
    {
      name: 'format_time',
      func: this.formatTime.bind(this),
      description:
        'Turns an hour, minute and am/pm into a string ready for a digital display',
    },
  ]
}
