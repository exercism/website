import React, { useContext } from 'react'
import { StepButton } from './components/StepButton'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { TrackContext } from '../../TrackWelcomeModal'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function SelectedLocalMachineStep({
  onContinueToLocalMachine,
}: Record<'onContinueToLocalMachine', () => void>): JSX.Element {
  const { track, send, links } = useContext(TrackContext)
  const { t } = useAppTranslation(
    'components/modals/track-welcome-modal/LHS/steps'
  )

  return (
    <>
      <h3 className="text-h3 mb-8">{t('selectedLocalMachineStep.title')}</h3>
      <p className="mb-8">{t('selectedLocalMachineStep.subtitle')}</p>

      <ol className="list-decimal pl-16 mb-16">
        <li>
          <Trans
            ns="components/modals/track-welcome-modal/LHS/steps"
            i18nKey="selectedLocalMachineStep.step1"
            components={{
              cliLink: (
                <a
                  href={links.cliWalkthrough}
                  target="_blank"
                  rel="noopener noreferrer"
                />
              ),
            }}
          />
        </li>
        <li>
          <Trans
            ns="components/modals/track-welcome-modal/LHS/steps"
            i18nKey="selectedLocalMachineStep.step2"
            values={{ trackTitle: track.title }}
            components={{
              toolingLink: (
                <a
                  href={links.trackTooling}
                  target="_blank"
                  rel="noopener noreferrer"
                />
              ),
            }}
          />
        </li>
        <li>
          {t('selectedLocalMachineStep.step3')}
          <CopyToClipboardButton textToCopy={links.downloadCmd} />
        </li>
      </ol>

      <div className="text-17 leading-huge mb-16">
        <Trans
          ns="components/modals/track-welcome-modal/LHS/steps"
          i18nKey="selectedLocalMachineStep.doneMessage"
          components={{
            strong: <strong className="font-semibold" />,
            code: (
              <code className="inline-block bg-backgroundColorD px-8 rounded-2">
                <pre />
              </code>
            ),
          }}
        />
      </div>

      <div className="flex gap-8">
        <StepButton
          onClick={onContinueToLocalMachine}
          className="btn-primary flex-grow"
        >
          {t('selectedLocalMachineStep.continue')}
        </StepButton>
        <StepButton
          onClick={() => send('RESET')}
          className="btn-secondary w-1-3"
        >
          {t('selectedLocalMachineStep.reset')}
        </StepButton>
      </div>
    </>
  )
}
