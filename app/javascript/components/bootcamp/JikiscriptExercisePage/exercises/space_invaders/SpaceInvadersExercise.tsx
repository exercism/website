import React from 'react'
import { Exercise } from '../Exercise'
import { ExecutionContext } from '@/interpreter/executor'
import { cloneDeep } from 'lodash'
import { deepTrim } from '@/interpreter/describers/helpers'
import { isNumber } from '@/interpreter/checks'
import { extractFunctionCallExpressions } from '../../test-runner/generateAndRunTestSuite/checkers'
import {
  RepeatUntilGameOverStatement,
  Statement,
} from '@/interpreter/statement'
import { InterpretResult } from '@/interpreter/interpreter'
import * as Jiki from '@/interpreter/jikiObjects'
import { exec } from 'child_process'

type GameStatus = 'running' | 'won' | 'lost'
type AlienStatus = 'alive' | 'dead'
class Alien {
  public status: AlienStatus
  public lastKilledAt?: number
  public respawnsAt?: number

  public constructor(
    public elem: HTMLElement,
    row: number,
    col: number,
    type: number
  ) {
    this.status = 'alive'
  }

  public isAlive(time) {
    if (this.status == 'alive') {
      return true
    }
    if (this.respawnsAt === undefined) {
      return false
    }

    return time > this.respawnsAt
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
  private features = { alienRespawning: false }

  public constructor() {
    super('space-invaders')

    this.laser = document.createElement('div')
    this.laser.classList.add('laser')
    this.laser.style.left = `${this.laserPositions[this.laserPosition]}%`
    this.view.appendChild(this.laser)
  }

  public getState() {
    return { gameStatus: this.gameStatus }
  }

  public setupAliens(_: ExecutionContext, rows: number[][]) {
    this.aliens = rows.map((row, rowIdx) => {
      return row.map((type, colIdx) => {
        if (type === 0) return null
        return this.addAlien(rowIdx, colIdx, type)
      })
    })
    this.startingAliens = cloneDeep(this.aliens)
  }

  public enableAlienRespawning() {
    this.features.alienRespawning = true
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
    executionCtx.fastForward(1)
    this.respawnAlien(executionCtx, alien)
  }

  private respawnAlien(executionCtx: ExecutionContext, alien: Alien) {
    if (!this.features.alienRespawning) {
      return
    }

    // Only respawn each alien once
    if (alien.respawnsAt !== undefined) {
      alien.respawnsAt = undefined
      return
    }

    // Stop respawning aliens after the first few seconds
    if (executionCtx.getCurrentTime() > 5000) {
      return
    }

    // Skip 80% of the time
    if (Math.random() > 0.3) {
      return
    }

    const respawnsAt = executionCtx.getCurrentTime() + this.shotDuration + 1000
    alien.respawnsAt = respawnsAt
    ;['tl', 'tr', 'bl', 'br'].forEach((pos) => {
      this.addAnimation({
        targets: `#${this.view.id} #${alien.elem.id} .${pos}`,
        duration: 1,
        transformations: { translateX: 0, translateY: 0, rotate: 0 },
        offset: respawnsAt,
      })
      this.addAnimation({
        targets: `#${this.view.id} #${alien.elem.id} .${pos}`,
        duration: 100,
        transformations: { opacity: 1 },
        offset: respawnsAt,
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

  private allAliensDead(executionCtx: ExecutionContext) {
    return this.aliens.every((row) =>
      row.every(
        (alien) =>
          alien === null || !alien.isAlive(executionCtx.getCurrentTime())
      )
    )
  }

  private checkForWin(executionCtx: ExecutionContext) {
    if (this.allAliensDead(executionCtx)) {
      this.gameStatus = 'won'
      executionCtx.updateState('gameOver', true)
    }
  }

  public isAlienAbove(executionCtx: ExecutionContext): Jiki.Boolean {
    return new Jiki.Boolean(
      this.aliens.some((row) => {
        const alien = row[this.laserPosition]
        if (alien === null) {
          return false
        }
        return alien.isAlive(executionCtx.getCurrentTime())
      })
    )
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
      if (alien == null) {
        return
      }
      if (!alien.isAlive(executionCtx.getCurrentTime())) {
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

      // Let the bullet leave the laser before moving
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

  public getStartingAliensInRow(
    executionCtx: ExecutionContext,
    row: Jiki.Number
  ): Jiki.List {
    if (!isNumber(row.value)) {
      executionCtx.logicError(
        'Oh no, the row input you provided is not a number.'
      )
    }

    if (row.value < 1 || row.value > this.startingAliens.length) {
      executionCtx.logicError(
        deepTrim(`
          Oh no, you tried to access a row of aliens that doesn't exist.
          You asked for row ${row.value}, but there are only ${this.startingAliens.length} rows of aliens.
        `)
      )
    }

    return new Jiki.List(
      this.startingAliens
        .slice()
        .reverse()
        [row.value - 1].map((alien) => alien !== null)
        .map((alive) => new Jiki.Boolean(alive))
    )
  }

  public getStartingAliens(_: ExecutionContext) {
    return [...this.startingAliens.map((row) => row.map(Boolean))]
  }

  fireFireworks(executionCtx: ExecutionContext) {
    if (!this.allAliensDead(executionCtx)) {
      executionCtx.logicError(
        'You need to defeat all the aliens before you can celebrate!'
      )
    }
    super.fireFireworks(
      executionCtx,
      executionCtx.getCurrentTime() + this.shotDuration
    )

    executionCtx.fastForward(2500)
    executionCtx.updateState('gameOver', true)
  }

  public wasFireworksCalledInsideRepeatLoop(result: InterpretResult) {
    const callsInsideRepeat = (statements) =>
      statements
        .filter((obj) => obj)
        .map((elem: Statement) => {
          if (elem instanceof RepeatUntilGameOverStatement) {
            return extractFunctionCallExpressions(elem.body).filter(
              (expr) => expr.callee.name.lexeme === 'fire_fireworks'
            )
          }
          return callsInsideRepeat(elem.children())
        })
        .flat()

    const callsOutsideRepeat = (statements) =>
      statements
        .filter((obj) => obj)
        .map((elem: Statement) => {
          if (elem instanceof RepeatUntilGameOverStatement) {
            return []
          }
          return callsOutsideRepeat(elem.children())
        })
        .flat()

    return (
      callsInsideRepeat(result.meta.statements).length > 0 &&
      callsOutsideRepeat(result.meta.statements).length === 0
    )
  }

  public availableFunctions = [
    {
      name: 'move_left',
      func: this.moveLeft.bind(this),
      description: 'moved the laser canon to the left',
    },
    {
      name: 'moveLeft',
      func: this.moveLeft.bind(this),
      description: 'moved the laser canon to the left',
    },
    {
      name: 'move_right',
      func: this.moveRight.bind(this),
      description: 'moved the laser canon to the right',
    },
    {
      name: 'moveRight',
      func: this.moveRight.bind(this),
      description: 'moved the laser canon to the right',
    },
    {
      name: 'shoot',
      func: this.shoot.bind(this),
      description: 'shot the laser upwards',
    },
    {
      name: 'is_alien_above',
      func: this.isAlienAbove.bind(this),
      description: 'determined if there was an alien above the laser canon',
    },
    {
      name: 'get_starting_aliens_in_row',
      func: this.getStartingAliensInRow.bind(this),
      description: 'retrieved the starting positions of row ${arg1} of aliens',
    },
    {
      name: 'getStartingAliens',
      func: this.getStartingAliens.bind(this),
      description: 'retrieved the starting positions of row ${arg1} of aliens',
    },
    {
      name: 'fire_fireworks',
      func: this.fireFireworks.bind(this),
      description: 'fired off celebratory fireworks',
    },
  ]
}
