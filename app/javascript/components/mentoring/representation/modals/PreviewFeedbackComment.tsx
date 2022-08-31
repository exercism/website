import React, { useEffect, useState } from 'react'
import { sendRequest } from '../../../../utils/send-request'
import { Avatar } from '../../../common'
import { User } from '../../../types'

export type PreviewFeedbackCommentProps = {
  markdown: string
  mentor: Pick<User, 'avatarUrl' | 'handle'> & { name: string }
}

export function PreviewFeedbackComment({
  markdown,
  mentor,
}: PreviewFeedbackCommentProps): JSX.Element {
  const [html, setHtml] = useState('<p>Loading</p>')

  const endpoint = document.querySelector<HTMLMetaElement>(
    'meta[name="parse-markdown-url"]'
  )?.content

  const { fetch } = sendRequest<{ html: string }>({
    //TODO work this out.
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
        <Avatar className="w-[32px] h-[32px] mr-16" src={mentor.avatarUrl} />
        <div className="text-15 text-btnBorder font-medium">
          <span className="text-primaryBtnBorder">{mentor.name}</span> gave this
          feedback on a solution exactly like yours:
        </div>{' '}
      </div>

      <div className="mb-4" dangerouslySetInnerHTML={{ __html: html }}></div>
      <div className="text-btnBorder font-medium">
        Commented on {Date.now()}
      </div>
    </div>
  )
}
