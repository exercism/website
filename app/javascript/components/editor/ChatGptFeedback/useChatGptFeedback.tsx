import { useEffect, useState } from 'react'
import { MutateFunction, useMutation } from 'react-query'
import { AIHelpRecordsChannel } from '@/channels/aiHelpRecordsChannel'
import { Submission } from '../types'
import { sendRequest } from '@/utils'

export type HelpRecord = {
  source: string
  advice_html: string
}

export type FetchingStatus = 'unfetched' | 'fetching' | 'received'

export type useChatGptFeedbackProps = {
  helpRecord: HelpRecord | undefined | null
  unfetched: boolean
  mutation: MutateFunction<void, unknown, undefined, unknown>
  setStatus: React.Dispatch<React.SetStateAction<FetchingStatus>>
  status: FetchingStatus
}

type Response = {
  help_record: HelpRecord
}
export function useChatGptFeedback({
  submission,
}: {
  submission: Submission
}): useChatGptFeedbackProps {
  const [helpRecord, setHelpRecord] = useState<HelpRecord | undefined>(
    undefined
  )
  const [status, setStatus] = useState<FetchingStatus>('unfetched')

  const [mutation] = useMutation<void>(async () => {
    const { fetch } = sendRequest({
      endpoint: submission.links.aiHelp,
      method: 'POST',
      body: null,
    })

    return fetch.then(() => setStatus('fetching'))
  })

  useEffect(() => {
    const solutionChannel = new AIHelpRecordsChannel(
      submission.uuid,
      (response: Response) => {
        setHelpRecord(response.help_record)
        setStatus('received')
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [mutation, submission.uuid])

  return {
    helpRecord,
    mutation,
    unfetched: helpRecord === undefined,
    status,
    setStatus,
  }
}
