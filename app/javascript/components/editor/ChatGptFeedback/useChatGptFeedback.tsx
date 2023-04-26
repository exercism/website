import { useEffect, useState } from 'react'
import { MutateFunction, useMutation } from 'react-query'
import { AIHelpRecordsChannel } from '@/channels/aiHelpRecordsChannel'
import { Submission } from '../types'
import { sendRequest } from '@/utils'

type HelpRecord = {
  source: string
  advice_html: string
}

export type useChatGptFeedbackProps = {
  helpRecord: HelpRecord | undefined | null
  mutation: MutateFunction<void, unknown, undefined, unknown>
}

type Response = {
  help_record: HelpRecord
}
export function useChatGptFeedback({
  submission,
}: {
  submission: Submission
}): useChatGptFeedbackProps {
  const [helpRecord, setHelpRecord] = useState<HelpRecord | null | undefined>(
    undefined
  )

  const [mutation] = useMutation<void>(async () => {
    const { fetch } = sendRequest({
      endpoint: submission.links.aiHelp,
      method: 'POST',
      body: null,
    })

    return fetch.then(() => setHelpRecord(null))
  })

  useEffect(() => {
    const solutionChannel = new AIHelpRecordsChannel(
      submission.uuid,
      (response: Response) => {
        setHelpRecord(response.help_record)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [mutation, submission.uuid])

  return { helpRecord, mutation }
}
