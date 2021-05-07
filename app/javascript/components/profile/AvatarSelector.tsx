import React, { useReducer } from 'react'
import 'react-image-crop/lib/ReactCrop.scss'
import { User } from '../types'
import { InitializedStep } from './avatar-selector/InitializedStep'
import { CroppingStep } from './avatar-selector/CroppingStep'
import { CropFinishedStep } from './avatar-selector/CropFinishedStep'
import { reducer, State, Action } from './avatar-selector/reducer'

export type Status = 'initialized' | 'cropping' | 'cropFinished'

type Links = {
  update: string
}

export const CROP_DEFAULTS = {
  aspect: 1 / 1,
}

export const AvatarSelector = ({
  user,
  links,
}: {
  user: User
  links: Links
}): JSX.Element => {
  const [state, dispatch] = useReducer(reducer, {
    avatarUrl: user.avatarUrl,
    status: 'initialized',
    cropSettings: CROP_DEFAULTS,
    imageToCrop: null,
    croppedImage: null,
  })

  return (
    <div className="avatar-selector">
      <CurrentStep
        user={user}
        state={state}
        dispatch={dispatch}
        links={links}
      />
      <h2>Your profile picture</h2>
      <div className="instructions">Click / tap it to upload another</div>
      <div className="formats">.jpg + .png accepted</div>
    </div>
  )
}

const CurrentStep = ({
  user,
  state,
  dispatch,
  links,
}: {
  user: User
  state: State
  dispatch: React.Dispatch<Action>
  links: Links
}) => {
  switch (state.status) {
    case 'initialized':
      return <InitializedStep user={user} state={state} dispatch={dispatch} />
    case 'cropping':
      return <CroppingStep state={state} dispatch={dispatch} />
    case 'cropFinished':
      return (
        <CropFinishedStep state={state} dispatch={dispatch} links={links} />
      )
    default:
      return null
  }
}
