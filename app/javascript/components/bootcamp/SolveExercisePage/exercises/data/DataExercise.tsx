import React from 'react'
import type { ExecutionContext } from '@/interpreter/executor'
import { Exercise } from '../Exercise'
import * as Jiki from '@/interpreter/jikiObjects'
import { offset } from '@popperjs/core'
import { InterpretResult } from '@/interpreter/interpreter'

export default class DataExercise extends Exercise {
  public constructor() {
    super('data')
  }

  public getState() {
    return {}
  }

  private fetchData(
    executionCtx: ExecutionContext,
    url: Jiki.String,
    params: Jiki.Dictionary
  ): Jiki.Dictionary {
    console.log(url)
    if (!(url instanceof Jiki.String))
      return executionCtx.logicError('URL must be a string')
    if (!(params instanceof Jiki.Dictionary))
      return executionCtx.logicError('Params must be a dictionary')

    if (url.value.startsWith('https://api.spotify.com/v1/users/')) {
      return this.spotifyUserRequest(executionCtx, url.value)
    }
    if (url.value.startsWith('https://api.spotify.com/v1/artists/')) {
      return this.spotifyArtistRequest(executionCtx, url.value)
    } else {
      return Jiki.wrapJSToJikiObject({ error: 'Unknown URL' })
    }
  }

  private spotifyUserRequest(
    executionCtx: ExecutionContext,
    url: string
  ): Jiki.Dictionary {
    const emptyDict = Jiki.wrapJSToJikiObject({ items: [] })

    // Extract username from https://api.spotify.com/v1/users/{username}
    // using a regexp where username can be a-z
    const match = url.match(
      /https:\/\/api\.spotify\.com\/v1\/users\/([a-zA-Z]+)/
    )
    if (match === null)
      return Jiki.wrapJSToJikiObject({ error: 'Could not parse URL' })
    const username = match[1]
    if (username === null)
      return Jiki.wrapJSToJikiObject({ error: 'Could not parse URL' })

    let artists: string[] | undefined
    switch (username) {
      case 'iHiD':
        artists = [
          '0vEsuISMWAKNctLlUAhSZC',
          '2d0hyoQ5ynDBnkvAbJKORj',
          '14r9dR01KeBLFfylVSKCZQ',
          '7dGJo4pcD2V6oG8kP0tJRR',
          '7EQ0qTo7fWT7DPxmxtSYEc',
        ]
        break
      default:
        return Jiki.wrapJSToJikiObject({ error: 'Unknown user' })
    }
    if (!artists) return emptyDict

    return Jiki.wrapJSToJikiObject({
      items: artists.map((id) => ({
        urls: { spotify_api: `https://api.spotify.com/v1/artists/${id}` },
      })),
    })
  }
  private spotifyArtistRequest(
    executionCtx: ExecutionContext,
    url: string
  ): Jiki.Dictionary {
    // Extract artist id from https://api.spotify.com/v1/artist/{id}
    // using a regexp where id can be a-z, A-Z, 0-9
    const match = url.match(
      /https:\/\/api\.spotify\.com\/v1\/artists\/([a-zA-Z0-9]+)/
    )
    if (match === null)
      return Jiki.wrapJSToJikiObject({ error: 'Could not parse URL' })
    const artistId = match[1]
    if (artistId === null)
      return Jiki.wrapJSToJikiObject({ error: 'Could not parse URL' })
    console.log(artistId)

    let name: string | undefined
    switch (artistId) {
      case '0vEsuISMWAKNctLlUAhSZC':
        name = 'Counting Crows'
        break
      case '2d0hyoQ5ynDBnkvAbJKORj':
        name = 'Rage Against The Machine'
        break
      case '14r9dR01KeBLFfylVSKCZQ':
        name = 'Damien Rice'
        break
      case '7dGJo4pcD2V6oG8kP0tJRR':
        name = 'Eminem'
        break
      case '7EQ0qTo7fWT7DPxmxtSYEc':
        name = 'Bastille'
        break
    }
    if (name === undefined) {
      return Jiki.wrapJSToJikiObject({ error: 'Unknown artist' })
    }
    return Jiki.wrapJSToJikiObject({ name })
  }

  public availableFunctions = [
    {
      name: 'fetch',
      func: this.fetchData.bind(this),
      description: 'fetched data from the provided URL',
    },
  ]
}
