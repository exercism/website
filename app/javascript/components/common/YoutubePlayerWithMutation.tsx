import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { YouTubePlayer } from './YoutubePlayer'
import { sendRequest } from '@/utils/send-request'

export default function YoutubePlayerWithMutation({ endpoint, id }) {
  const { mutate: markVideoAsSeen } = useMutation(async () => {
    const { fetch } = sendRequest({
      endpoint: endpoint,
      method: 'PATCH',
      body: null,
    })

    return fetch
  })
  return <YouTubePlayer id={id} onPlay={markVideoAsSeen} />
}
