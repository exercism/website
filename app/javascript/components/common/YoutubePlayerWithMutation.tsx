import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { YoutubePlayer } from './YoutubePlayer'

export default function YoutubePlayerWithMutation({ markAsSeenEndpoint, id }) {
  const { mutate: markVideoAsSeen } = useMutation(async () => {
    const { fetch } = sendRequest({
      endpoint: markAsSeenEndpoint,
      method: 'POST',
      body: null,
    })

    return fetch
  })
  return (
    <YoutubePlayer
      id={id}
      onPlay={markAsSeenEndpoint ? markVideoAsSeen : () => {}}
    />
  )
}
