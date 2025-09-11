import { useCallback, useContext } from 'react'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils'
import { GlossaryEntriesShowContext } from './index'
import { toast } from 'react-hot-toast'

type RequestConfig = {
  endpoint: string
  body: string | null | FormData
  method: string
}

export function useRequestWithNextRedirect() {
  const { links, glossaryEntry } = useContext(GlossaryEntriesShowContext)

  const redirectToNext = useCallback(async () => {
    try {
      const nextEntryEndpoint = `${links.nextEntry}?status=${glossaryEntry.status}&locale=${glossaryEntry.locale}&exclude_ids[]=${glossaryEntry.uuid}`
      console.log('Fetching next entry from:', nextEntryEndpoint)

      const { fetch: fetchNext } = sendRequest({
        method: 'GET',
        endpoint: nextEntryEndpoint,
        body: null,
      })

      const nextEntryResponse = await fetchNext
      console.log('Next entry response:', nextEntryResponse)

      if (!nextEntryResponse || !nextEntryResponse.uuid) {
        throw new Error('Invalid next entry response: missing uuid')
      }

      const redirectLink = `${links.localizationGlossaryEntriesPath}/${nextEntryResponse.uuid}`

      redirectTo(redirectLink)
    } catch (error) {
      console.error('Error in redirectToNext:', error)

      if (
        error &&
        typeof error === 'object' &&
        'status' in error &&
        error.status === 404
      ) {
        toast(
          'No more entries available in this category. Redirecting to the list page...',
          {
            duration: 3000,
          }
        )

        setTimeout(() => {
          redirectTo(links.glossaryEntriesListPage)
        }, 3000)

        return
      }

      throw error
    }
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
