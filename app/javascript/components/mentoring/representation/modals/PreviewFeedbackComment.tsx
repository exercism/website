import React, { useEffect, useState } from 'react'
import { sendRequest } from '../../../../utils/send-request'
import { Avatar } from '../../../common'

export type PreviewFeedbackCommentProps = {
  markdown: string
}

export function PreviewFeedbackComment({
  markdown,
}: PreviewFeedbackCommentProps): JSX.Element {
  const [html, setHtml] = useState('<p>Loading</p>')

  const endpoint = document.querySelector<HTMLMetaElement>(
    'meta[name="parse-markdown-url"]'
  )?.content

  const { fetch } = sendRequest<{ html: string }>({
    endpoint,
    method: 'POST',
    body: JSON.stringify({
      parse_options: {
        strip_h1: false,
        lower_heading_levels_by: 2,
      },
      markdown,
    }),
  })
  useEffect(() => {
    fetch.then((res) => setHtml(res.html))
  }, [])

  return (
    <div className="px-24 py-16 leading-160">
      <div className="flex flex-row items-center mb-12">
        <Avatar
          className="w-[32px] h-[32px] mr-16"
          src="https://exercism-v3-icons.s3.eu-west-2.amazonaws.com/placeholders/user-avatar.svg"
        />
        <div className="text-15 text-btnBorder font-medium">
          <span className="text-primaryBtnBorder">ErikSchierboom</span> gave
          this feedback on a solution exactly like yours:
        </div>{' '}
      </div>

      <div className="mb-4" dangerouslySetInnerHTML={{ __html: html }}></div>
      <div className="text-btnBorder font-medium">
        Commented on {Date.now()}
      </div>
    </div>
  )
}
