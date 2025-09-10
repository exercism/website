import { useCallback, useContext } from 'react'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils'
import { GlossaryEntriesShowContext } from './index'

type RequestConfig = {
  endpoint: string
  body: string | null | FormData
  method: string
}

export function useRequestWithNextRedirect() {
  const { links, glossaryEntry } = useContext(GlossaryEntriesShowContext)

  const redirectToNext = useCallback(async () => {
    const nextEntryEndpoint = `${links.nextEntry}?status=${glossaryEntry.status}&locale=${glossaryEntry.locale}`
    const { fetch: fetchNext } = sendRequest({
      method: 'GET',
      endpoint: nextEntryEndpoint,
      body: null,
    })

    const nextEntryResponse = await fetchNext
    const redirectLink = `${links.localizationGlossaryEntriesPath}/${nextEntryResponse.uuid}`

    redirectTo(redirectLink)
  }, [links, glossaryEntry])

  const sendRequestWithRedirect = useCallback(
    async (config: RequestConfig) => {
      try {
        const { fetch } = sendRequest(config)
        await fetch
        await redirectToNext()
      } catch (err) {
        console.error(err)
        throw err
      }
    },
    [redirectToNext]
  )

  const sendRequestWithoutRedirect = useCallback(
    async (config: RequestConfig) => {
      try {
        const { fetch } = sendRequest(config)
        return await fetch
      } catch (err) {
        console.error(err)
        throw err
      }
    },
    []
  )

  return {
    sendRequestWithRedirect,
    sendRequestWithoutRedirect,
    redirectToNext,
  }
}
