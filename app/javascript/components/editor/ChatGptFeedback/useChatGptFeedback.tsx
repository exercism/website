import { useCallback, useEffect, useState } from 'react'
import {
  MutationStatus,
  UseMutateFunction,
  useMutation,
} from '@tanstack/react-query'
import { AIHelpRecordsChannel } from '@/channels/aiHelpRecordsChannel'
import { sendRequest } from '@/utils/send-request'
import { camelizeKeysAs } from '@/utils/camelize-keys-as'
import { Submission } from '../types'
import { GPTModel as GPTModelType } from './ChatGptDialog'
import { GptUsage } from './ChatGptDialog'

export type HelpRecord = {
  source: string
  adviceHtml: string
}

export type AIHelpRecordsChannelResponse = {
  help_record: HelpRecord
  usage: GptUsage
}

export type FetchingStatus = 'unfetched' | 'fetching' | 'received'

export type useChatGptFeedbackProps = {
  helpRecord: HelpRecord | undefined | null
  unfetched: boolean
  mutation: UseMutateFunction<void, unknown, void, unknown>
  setStatus: React.Dispatch<React.SetStateAction<FetchingStatus>>
  status: FetchingStatus
  submissionUuid: string | undefined
  setSubmissionUuid: React.Dispatch<React.SetStateAction<string | undefined>>
  mutationStatus: MutationStatus
  mutationError: unknown
  exceededLimit: boolean
  chatGptUsage: GptUsage
}

export function useChatGptFeedback({
  submission,
  defaultRecord,
  GPTModel,
  chatgptUsage,
}: {
  submission: Submission | null
  defaultRecord: HelpRecord
  GPTModel: GPTModelType
  chatgptUsage: GptUsage
}): useChatGptFeedbackProps {
  const [helpRecord, setHelpRecord] = useState<HelpRecord | undefined>(
    defaultRecord
  )
  const [status, setStatus] = useState<FetchingStatus>(
    defaultRecord ? 'received' : 'unfetched'
  )
  const [submissionUuid, setSubmissionUuid] = useState<string | undefined>()
  const [exceededLimit, setExceededLimit] = useState(false)
  const [chatGptUsage, setChatGptUsage] = useState(chatgptUsage)

  const onError = useCallback((err) => {
    if (err.status === 402) {
      setExceededLimit(true)
    }
  }, [])

  const {
    mutate: mutation,
    status: mutationStatus,
    error: mutationError,
  } = useMutation<void>(
    async () => {
      if (!submission) return
      const { fetch } = sendRequest({
        endpoint: submission?.links.aiHelp,
        method: 'POST',
        body: JSON.stringify({ chatgpt_version: GPTModel }),
      })

      return fetch.then(() => setStatus('fetching'))
    },
    { onError }
  )

  useEffect(() => {
    if (!submission) return
    const solutionChannel = new AIHelpRecordsChannel(
      submission?.uuid,
      (response: AIHelpRecordsChannelResponse) => {
        setHelpRecord(camelizeKeysAs<HelpRecord>(response.help_record))
        setChatGptUsage(response.usage)
        setStatus('received')
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [mutation, submission])

  return {
    helpRecord,
    mutation,
    unfetched: helpRecord === undefined,
    status,
    setStatus,
    submissionUuid,
    setSubmissionUuid,
    mutationError,
    mutationStatus,
    exceededLimit,
    chatGptUsage,
  }
}
