import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'
import { random } from 'lodash'
import { d } from '@codemirror/legacy-modes/mode/d'

type GameStatus = 'running' | 'won' | 'lost'
type AlienStatus = 'alive' | 'dead'
class Alien {
  public status: AlienStatus
  public lastKilledAt?: number

  public constructor(
    public elem: HTMLElement,
    row: number,
    col: number,
    type: number
  ) {
    this.status = 'alive'
  }
}

export default class SpaceInvadersExercise extends Exercise {
  private gameStatus: GameStatus = 'running'
  private moveDuration = 200
  private shotDuration = 1000

  private minLaserPosition = 0
  private maxLaserPosition = 10
  private laserStart = 12
  private laserStep = 7.5
  private laserPositions = Array.from(
    { length: this.maxLaserPosition + 1 },
    (_, idx) => this.laserStart + idx * this.laserStep
  )
  private laserPosition = 0
  private features = { reanimation: false }

  public constructor() {
    super('space-invaders')

    this.laser = document.createElement('div')
    this.laser.classList.add('laser')
    this.laser.style.left = `${this.laserPositions[this.laserPosition]}%`
    this.view.appendChild(this.laser)

    this.addAliens([
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
      [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
    ])
  }

  public getState() {
    return { gameStatus: this.gameStatus }
  }

  public enableReanimation() {
    this.features.reanimation = true
  }

  private addAliens(rows) {
    this.aliens = rows.map((row, rowIdx) => {
      return row.map((type, colIdx) => {
        if (type === 0) return null
        return this.addAlien(rowIdx, colIdx, type)
      })
    })
  }

  private addAlien(row: number, col: number, type: number) {
    const alien = document.createElement('div')
    alien.classList.add('alien')
    alien.id = `alien-${Math.random().toString(36).slice(2, 11)}`
    alien.style.left = `${this.laserStart + col * this.laserStep}%`
    alien.style.top = `${10 + row * 11}%`

    const parts = ['tl', 'tr', 'bl', 'br']
    parts.forEach((pos) => {
      const part = document.createElement('div')
      part.classList.add(pos)
      alien.appendChild(part)
    })
    this.view.appendChild(alien)

    return new Alien(alien, row, col, type)
  }

  private killAlien(
    executionCtx: ExecutionContext,
    alien: Alien,
    shot: HTMLElement
  ) {
    const deathTime = executionCtx.getCurrentTime() + this.shotDuration

    alien.status = 'dead'
    alien.lastKilledAt = deathTime
    ;[
      ['tl', -10, -10, -180],
      ['tr', 10, -10, 180],
      ['bl', -10, 10, -180],
      ['br', 10, 10, 180],
    ].forEach(([pos, x, y, rotate]) => {
      this.addAnimation({
        targets: `#${this.view.id} #${alien.elem.id} .${pos}`,
        duration: 300,
        transformations: {
          translateX: x,
          translateY: y,
          rotate: rotate,
          opacity: 0,
        },
        offset: deathTime,
      })
    })
    this.addAnimation({
      targets: `#${this.view.id} #${shot.id}`,
      duration: 1,
      transformations: { opacity: 0 },
      offset: deathTime,
    })
  }

  private reanimateRandomAlien(executionCtx: ExecutionContext) {
    if (!this.features.reanimation) {
      return
    }

    const deadAliens = this.aliens
      .flat()
      .filter(
        (alien) =>
          alien !== null &&
          alien.status === 'dead' &&
          alien.lastKilledAt &&
          alien.lastKilledAt < executionCtx.getCurrentTime() + this.shotDuration
      )

    // Skip 80% of the time
    if (Math.random() > 0.2) {
      return
    }

    // Choose random dead alien from this.aliens
    const alien = deadAliens[Math.floor(Math.random() * deadAliens.length)]
    if (alien == null) {
      return
    }

    alien.status = 'alive'
    const renamationTime = executionCtx.getCurrentTime()

    ;['tl', 'tr', 'bl', 'br'].forEach((pos) => {
      this.addAnimation({
        targets: `#${this.view.id} #${alien.elem.id} .${pos}`,
        duration: 1,
        transformations: { translateX: 0, translateY: 0, rotate: 0 },
        offset: renamationTime,
      })
      this.addAnimation({
        targets: `#${this.view.id} #${alien.elem.id} .${pos}`,
        duration: 100,
        transformations: { opacity: 1 },
        offset: renamationTime,
      })
    })
  }

  private moveLaser(executionCtx: ExecutionContext) {
    this.addAnimation({
      targets: `#${this.view.id} .laser`,
      duration: this.moveDuration,
      transformations: {
        opacity: 1,
        left: `${this.laserPositions[this.laserPosition]}%`,
      },
      offset: executionCtx.getCurrentTime(),
    })
    executionCtx.fastForward(this.moveDuration)
  }

  private checkForWin(executionCtx: ExecutionContext) {
    const win = this.aliens.every((row) =>
      row.every((alien) => alien === null || alien.status === 'dead')
    )
    if (win) {
      this.gameStatus = 'won'
      executionCtx.updateState('gameOver', true)
    }
  }

  public isAlienAbove(executionCtx: ExecutionContext): boolean {
    return this.aliens.some((row) => {
      const alien = row[this.laserPosition]
      if (alien === null) {
        return false
      }
      if (alien.status == 'dead') {
        return false
      }

      return true
    })
  }

  public shoot(executionCtx: ExecutionContext) {
    if (this.lastShotAt > executionCtx.getCurrentTime() - 50) {
      executionCtx.logicError(
        'Oh no! Your laser canon overheated from shooting too fast! You need to move before you can shoot a second time.'
      )
    }
    this.lastShotAt = executionCtx.getCurrentTime()

    let targetRow = null
    let targetAlien: Alien | null = null
    this.aliens.forEach((row, rowIdx) => {
      const alien = row[this.laserPosition]
      if (alien === null) {
        return
      }
      if (alien.status == 'dead') {
        return
      }

      targetRow = rowIdx
      targetAlien = row[this.laserPosition]
    })

    let targetTop
    if (targetRow === null) {
      targetTop = -10
    } else {
      targetTop = `${10 + targetRow * 11}%`
    }

    // TODO: Vary speed based on distance
    const duration = this.shotDuration

    const shot = document.createElement('div')
    shot.classList.add('shot')
    shot.id = `shot-${Math.random().toString(36).slice(2, 11)}`
    shot.style.left = `${this.laserPositions[this.laserPosition]}%`
    shot.style.top = '85%'
    shot.style.opacity = '0'
    this.view.appendChild(shot)

    this.addAnimation({
      targets: `#${this.view.id} #${shot.id}`,
      duration: 1,
      transformations: { opacity: 1 },
      offset: executionCtx.getCurrentTime(),
    })
    this.addAnimation({
      targets: `#${this.view.id} #${shot.id}`,
      duration: duration,
      transformations: { top: targetTop },
      offset: executionCtx.getCurrentTime(),
      easing: 'linear',
    })

    if (targetAlien === null) {
      executionCtx.logicError('Oh no, you missed. Wasting ammo is not allowed!')
      this.gameStatus = 'lost'
      executionCtx.updateState('gameOver', true)
    } else {
      this.killAlien(executionCtx, targetAlien, shot)
      this.reanimateRandomAlien(executionCtx)

      // Why do we do this?
      executionCtx.fastForward(30)

      this.checkForWin(executionCtx)
    }
  }

  public moveLeft(executionCtx: ExecutionContext) {
    if (this.laserPosition == this.minLaserPosition) {
      executionCtx.logicError('Oh no, you tried to move off the edge!')
      executionCtx.updateState('gameOver', true)
    }

    this.laserPosition -= 1
    this.moveLaser(executionCtx)
  }

  public moveRight(executionCtx: ExecutionContext) {
    if (this.laserPosition == this.maxLaserPosition) {
      executionCtx.logicError('Oh no, you tried to move off the edge!')
      executionCtx.updateState('gameOver', true)
    }

    this.laserPosition += 1
    this.moveLaser(executionCtx)
  }

  public availableFunctions = [
    {
      name: 'runGame',
      func: this.runGame,
      description: '',
    },
    {
      name: 'move_left',
      func: this.moveLeft.bind(this),
      description: '',
    },
    {
      name: 'move_right',
      func: this.moveRight.bind(this),
      description: '',
    },
    {
      name: 'shoot',
      func: this.shoot.bind(this),
      description: '',
    },
    {
      name: 'is_alien_above',
      func: this.isAlienAbove.bind(this),
      description: '',
    },
  ]
}
