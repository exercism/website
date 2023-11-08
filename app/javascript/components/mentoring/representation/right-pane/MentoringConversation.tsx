import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import {
  CompleteRepresentationData,
  RepresentationFeedbackType,
} from '@/components/types'
import { PreviewAutomationModal } from '../modals/PreviewAutomationModal'
import { SubmittedAutomationModal } from '../modals/SubmittedAutomationModal'
import { RepresentationFeedbackEditor } from './RepresentationFeedbackEditor'

export default function MentoringConversation({
  data,
  feedbackType,
}: {
  data: CompleteRepresentationData
  feedbackType: RepresentationFeedbackType
}): JSX.Element {
  const [value, setValue] = useState(
    data.representation.feedbackMarkdown ||
      data.representation.draftFeedbackMarkdown ||
      ''
  )
  const [isSuccessModalOpen, setIsSuccessModalOpen] = useState(false)
  const [isPreviewModalOpen, setIsPreviewModalOpen] = useState(false)
  const [expanded, setExpanded] = useState(
    !!data.representation.feedbackMarkdown ||
      !!data.representation.draftFeedbackMarkdown ||
      false
  )
  const [html, setHtml] = useState('<p>Loading..</p>')

  const handleChange = useCallback((value) => setValue(value), [setValue])

  const handleExpansion = useCallback((expanded) => {
    if (!expanded) {
      setExpanded(true)
    }
  }, [])

  const handleCompression = useCallback((value) => {
    if (!value) {
      setExpanded(false)
    }
  }, [])

  const { mutate: generateHTML } = useMutation(async (markdown: string) => {
    const { fetch } = sendRequest<{ html: string }>({
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      // querySelector may return undefined, but not in this case.
      endpoint: document.querySelector<HTMLMetaElement>(
        'meta[name="parse-markdown-url"]'
      )?.content,
      method: 'POST',
      body: JSON.stringify({
        parse_options: {
          strip_h1: false,
          lower_heading_levels_by: 2,
        },
        markdown,
      }),
    })
    return fetch.then((res) => {
      setHtml(`<div class="c-textual-content --small">${res.html}</div>`)
    })
  })

  const handlePreviewClick = useCallback(() => {
    setIsPreviewModalOpen(true)
    generateHTML(value)
  }, [generateHTML, value])

  return (
    <div>
      <RepresentationFeedbackEditor
        onChange={handleChange}
        value={value}
        expanded={expanded}
        onFocus={() => handleExpansion(expanded)}
        onBlur={() => handleCompression(value)}
        onPreviewClick={handlePreviewClick}
      />

      <PreviewAutomationModal
        feedbackType={feedbackType}
        markdown={value}
        data={data}
        isOpen={isPreviewModalOpen}
        html={html}
        onClose={() => setIsPreviewModalOpen(false)}
        onSuccessfulSubmit={() => {
          setIsPreviewModalOpen(false)
          setIsSuccessModalOpen(true)
        }}
      />
      <SubmittedAutomationModal
        goBackLink={data.links.success}
        isOpen={isSuccessModalOpen}
        onClose={() => setIsSuccessModalOpen(false)}
      />
    </div>
  )
}
