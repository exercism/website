// i18n-key-prefix: testSummary
// i18n-namespace: components/editor/testComponents
import React, { useCallback } from 'react'
import { TestStatus, Test } from '../types'
import { GraphicalIcon } from '../../common/GraphicalIcon'
import { useHighlighting } from '../../../utils/highlight'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const statusLabels = {
  [TestStatus.PASS]: 'Passed',
  [TestStatus.FAIL]: 'Failed',
  [TestStatus.ERROR]: 'Failed',
}
const messageLabels = {
  [TestStatus.PASS]: null,
  [TestStatus.FAIL]: 'Test Failure',
  [TestStatus.ERROR]: 'Test Error',
}

export function TestSummary({
  test,
  defaultOpen,
  language,
}: {
  test: Test
  defaultOpen: boolean
  language: string
}): JSX.Element {
  const { t } = useAppTranslation('components/editor/testComponents')

  const isPresent = useCallback((str) => {
    return str !== undefined && str !== null && str !== ''
  }, [])

  const testCodeRef = useHighlighting<HTMLPreElement>()

  return (
    <details
      className={`c-details c-test-summary ${test.status}`}
      open={defaultOpen}
    >
      <summary className="--summary">
        <div className="--summary-inner">
          <div className="--status">
            <div className="--dot" />
            <span>
              {t(`testSummary.${statusLabels[test.status].toLowerCase()}`)}
            </span>
          </div>
          <div className="--summary-details">
            <div className="--summary-idx">
              {t('testSummary.test')} {test.index}
            </div>
            <div className="--summary-name">{test.name}</div>
          </div>
          <GraphicalIcon icon="chevron-right" className="--closed-icon" />
          <GraphicalIcon icon="chevron-down" className="--open-icon" />
        </div>
      </summary>
      <div className="--explanation">
        {isPresent(test.testCode) ? (
          <div className="--info">
            <h3>{t('testSummary.codeRun')}</h3>
            <pre ref={testCodeRef}>
              <code className={language}>{test.testCode}</code>
            </pre>
          </div>
        ) : null}
        {isPresent(test.message) ? (
          <div className="--info">
            <h3>{messageLabels[test.status]}</h3>
            <pre dangerouslySetInnerHTML={{ __html: test.messageHtml }} />
          </div>
        ) : null}
        {isPresent(test.output) ? (
          <div className="--info">
            <h3>{t('testSummary.yourOutput')}</h3>
            <pre dangerouslySetInnerHTML={{ __html: test.outputHtml }} />
          </div>
        ) : null}
      </div>
    </details>
  )
}
