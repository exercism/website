import React, { useContext, useEffect, useRef } from 'react'
import { renderLog } from '@/components/bootcamp/JikiscriptExercisePage/RHS/Logger/renderLog'
import { useHighlighting } from '@/utils/highlight'
import { useFrontendExercisePageStore } from '../../../store/frontendExercisePageStore'
import { FrontendExercisePageContext } from '../../../FrontendExercisePageContext'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Logger() {
  const { t } = useAppTranslation(
    'components/bootcamp/FrontendExercisePage/RHS'
  )
  const containerRef = useRef<HTMLDivElement>(null)

  const { logs, setLogs } = useFrontendExercisePageStore()

  const { jsCodeRunId } = useContext(FrontendExercisePageContext)

  const ref = useHighlighting<HTMLDivElement>()

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data?.type === 'iframe-log') {
        const newLogs = event.data.logs as unknown[][]
        const logRunId = event.data.runId

        if (logRunId === jsCodeRunId.current) {
          setLogs((prev) => [...prev, ...newLogs])
        } else {
          console.debug('Ignoring stale logs: ', newLogs)
        }
      }
    }

    window.addEventListener('message', handleMessage)
    return () => window.removeEventListener('message', handleMessage)
  }, [])

  useEffect(() => {
    const el = document.querySelector('.panels')
    if (el) {
      el.scrollTop = el.scrollHeight
    }
  }, [logs])

  return (
    <div className="c-logger" ref={ref}>
      <h2>{t('panels.consolePanel.logger.logMessages')}</h2>
      {logs.length === 0 ? (
        <div className="info-message">
          <p>
            {t('panels.consolePanel.logger.useTheLogFunction')}
            e.g.
          </p>
          <pre className="hljs language-javascript">
            <code>{t('panels.consolePanel.logger.helloWorldExample')}</code>
          </pre>
        </div>
      ) : (
        <>
          <div className="info-message">
            <p>{t('panels.consolePanel.logger.theseAreTheLogMessages')}</p>
          </div>
          <div className="log-container" ref={containerRef}>
            {logs.map((logArgs, index) => (
              <pre key={index} className="log">
                {renderLog(logArgs)}
              </pre>
            ))}
          </div>
        </>
      )}
    </div>
  )
}
