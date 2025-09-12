// i18n-key-prefix: openEditor
// i18n-namespace: components/student/OpenEditorButton.tsx
import React, { JSXElementConstructor } from 'react'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import {
  ComboButton,
  PrimarySegment,
  DropdownSegment,
} from '@/components/common/ComboButton'
import { GenericTooltip } from '@/components/misc/ExercismTippy'
import { StartExerciseButton } from './open-editor-button/StartExerciseButton'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

type Props =
  | {
      editorEnabled: boolean
      status: 'locked'
      command: string
      links: { local: string }
    }
  | {
      editorEnabled: boolean
      status: 'available'
      command: string
      links: { start: string; local: string }
    }
  | {
      editorEnabled: boolean
      status: 'completed' | 'published'
      command: string
      links: { exercise: string; local: string }
    }
  | {
      editorEnabled: boolean
      status: 'iterated' | 'started'
      command: string
      links: { exercise: string; local: string }
    }

export default function OpenEditorButton(props: Props): JSX.Element | null {
  return (
    <ButtonTooltip {...props}>
      <ComboButton enabled={props.status !== 'locked'}>
        <PrimarySegment>
          <Button {...props} />
        </PrimarySegment>
        <DropdownSegment>
          <DropdownPanel {...props} />
        </DropdownSegment>
      </ComboButton>
    </ButtonTooltip>
  )
}

const Button = (props: Props & { className?: string }) => {
  const { t } = useAppTranslation()

  switch (props.status) {
    case 'locked':
      return props.editorEnabled ? (
        <div className={props.className}>{t('openEditor.openInEditor')}</div>
      ) : (
        <button className={`${props.className} --disabled`}>
          {t('openEditor.openInEditor')}
        </button>
      )
    case 'available':
      return props.editorEnabled ? (
        <StartExerciseButton
          endpoint={props.links.start}
          className={props.className}
        />
      ) : (
        <button className={`${props.className} --disabled`}>
          {t('openEditor.startInEditor')}
        </button>
      )
    case 'published':
    case 'completed':
      return props.editorEnabled ? (
        <a href={props.links.exercise} className={props.className}>
          {t('openEditor.openInEditor')}
        </a>
      ) : (
        <button className={`${props.className} --disabled`}>
          {t('openEditor.openInEditor')}
        </button>
      )
    default:
      return props.editorEnabled ? (
        <a href={props.links.exercise} className={props.className}>
          {t('openEditor.continueInEditor')}
        </a>
      ) : (
        <button className={`${props.className} --disabled`}>
          {t('openEditor.continueInEditor')}
        </button>
      )
  }
}

const DropdownPanel = ({
  editorEnabled,
  command,
  links,
}: {
  editorEnabled: boolean
  command: string
  links: { local: string }
}) => {
  const { t } = useAppTranslation()

  const downloadPrompt = editorEnabled
    ? t('openEditor.downloadPrompt')
    : t('openEditor.exerciseNotAvailable')

  return (
    <div className="c-open-editor-button-dropdown">
      <h3>{t('openEditor.downloadAndWorkLocally')}</h3>
      <p>{t('openEditor.youCanWorkLocally', { downloadPrompt })}</p>
      <CopyToClipboardButton textToCopy={command} />

      <p>
        <Trans
          i18nKey="openEditor.firstTimeUsingSetup"
          components={{
            link: <a href={links.local} target="_blank" rel="noreferrer" />,
          }}
        />
      </p>
    </div>
  )
}

const ButtonTooltip = ({
  status,
  editorEnabled,
  children,
}: {
  status: string
  editorEnabled: boolean
  children:
    | React.ReactElement<any, string | JSXElementConstructor<any>>
    | undefined
}): JSX.Element | null => {
  const { t } = useAppTranslation()

  if (!editorEnabled) {
    const content = (
      <>
        <p>{t('openEditor.onlineEditorNotAvailable')}</p>
        <p>{t('openEditor.clickArrowForMoreInfo')}</p>
      </>
    )
    return <GenericTooltip content={content}>{children}</GenericTooltip>
  }

  if (status === 'locked') {
    return (
      <GenericTooltip content={t('openEditor.exerciseCurrentlyLocked')}>
        {children}
      </GenericTooltip>
    )
  }

  return <React.Fragment>{children}</React.Fragment>
}
