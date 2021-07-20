import React, { useRef, useState } from 'react'
import { GraphicalIcon, Icon } from './'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { FormButton } from './FormButton'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to hide introducer')

type IntroducerSize = 'small' | 'base'

export const Introducer = ({
  icon,
  content,
  children,
  endpoint,
  size = 'base',
}: React.PropsWithChildren<{
  icon: string
  content?: string
  endpoint: string
  size?: IntroducerSize
}>): JSX.Element | null => {
  const [hidden, setHidden] = useState(false)
  const ref = useRef<HTMLDivElement | null>(null)
  const [mutation, { status, error }] = useMutation(
    () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        setHidden(true)
      },
    }
  )

  const wrapperClassNames = [
    'c-introducer-wrapper',
    hidden ? 'hidden' : '',
  ].filter((className) => className.length > 0)

  return (
    <div className={wrapperClassNames.join(' ')}>
      <div ref={ref} className={`c-introducer --${size}`}>
        <GraphicalIcon
          icon={icon}
          category="graphics"
          className="visual-icon"
        />
        {content ? (
          <div className="info" dangerouslySetInnerHTML={{ __html: content }} />
        ) : null}
        {children ? <div className="info">{children}</div> : null}
        {endpoint ? (
          <>
            <FormButton
              className="close"
              type="button"
              onClick={() => mutation()}
              status={status}
            >
              <Icon icon="close" alt="Permanently hide this introducer" />
            </FormButton>
            <ErrorBoundary resetKeys={[status]}>
              <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
            </ErrorBoundary>
          </>
        ) : null}
      </div>
    </div>
  )
}
