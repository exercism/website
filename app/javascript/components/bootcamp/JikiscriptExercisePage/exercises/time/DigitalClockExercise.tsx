import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'
import * as Jiki from '@/interpreter/jikiObjects'

export default class DigitalClockExercise extends Exercise {
  private displayedTime?: String
  private hours: number
  private minutes: number

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
  public setTime(_: ExecutionContext, hours: number, minutes: number) {
    this.hours = hours
    this.minutes = minutes
  }

  public didDisplayCurrentTime(_: ExecutionContext) {
    if (this.displayedTime === undefined) {
      return false
    }

    let normalisedHours = this.hours
    const ampm = this.hours >= 12 ? 'pm' : 'am'
    if (this.hours == 0) {
      normalisedHours = 12
    } else if (this.hours > 12) {
      normalisedHours = this.hours - 12
    }

    return this.displayedTime == `${normalisedHours}:${this.minutes}${ampm}`
  }
  public currentTimeHour(_: ExecutionContext): Jiki.Number {
    return new Jiki.Number(this.hours)
  }
  public currentTimeMinute(_: ExecutionContext): Jiki.Number {
    return new Jiki.Number(this.minutes)
  }
  public displayTime(
    _: ExecutionContext,
    hours: Jiki.String,
    mins: Jiki.String,
    ampm: Jiki.String
  ) {
    this.displayedTime = `${hours.value}:${mins.value}${ampm.value}`

    const [h1, h2] = String(hours.value).padStart(2, '0').split('')
    const [m1, m2] = String(mins.value).padStart(2, '0').split('')

    this.h1Elem.innerText = h1
    this.h2Elem.innerText = h2
    this.m1Elem.innerText = m1
    this.m2Elem.innerText = m2

    if (ampm.value === 'am' || ampm.value === 'pm') {
      this.meridiem.innerText = ampm.value
      this.meridiem.classList.add(ampm.value)
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
