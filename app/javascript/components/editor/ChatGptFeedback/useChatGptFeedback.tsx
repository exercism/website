import { useEffect, useState } from 'react'
import { useMutation, useQueryCache } from 'react-query'
import { useLogger } from '@/hooks'
import { AIHelpRecordsChannel } from '@/channels/aiHelpRecordsChannel'
import { Submission } from '../types'
import { sendRequest } from '@/utils'

const REFETCH_INTERVAL = 2000

type HelpRecord = {
  source: string
  advice_html: string
}
export function useChatGptFeedback({
  submission,
}: {
  submission: Submission
}): { advice: HelpRecord | undefined } {
  const [advice, setAdvice] = useState<HelpRecord>()

  const queryCache = useQueryCache()
  const CACHE_KEY = `editor-${submission.uuid}-chatgpt-feedback`

  const [queryEnabled, setQueryEnabled] = useState(false)

  const [mutation, { status, error }] = useMutation<void>(
    () => {
      const { fetch } = sendRequest({
        endpoint: submission.links.aiHelp,
        method: 'POST',
        body: null,
      })

      return fetch.then((json) => setAdvice(json))
    },
    {
      onSuccess: (data) => console.log(data),
    }
  )

  useEffect(() => {
    mutation()
    const solutionChannel = new AIHelpRecordsChannel(
      submission.uuid,
      (response) => {
        // queryCache.setQueryData(CACHE_KEY, { response })
        setAdvice(response as any)
      }
    )

    console.log(solutionChannel)

    return () => {
      solutionChannel.disconnect()
    }
  }, [mutation, submission.uuid])
  useLogger('advice', advice)

  return { advice }
}
