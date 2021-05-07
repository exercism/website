import React, { useCallback } from 'react'
import { Avatar } from '../../common'
import { User } from '../../types'
import { State, Action } from './reducer'

export const InitializedStep = ({
  user,
  state,
  dispatch,
}: {
  user: User
  state: State
  dispatch: React.Dispatch<Action>
}): JSX.Element => {
  const handleFileAttach = useCallback(
    (e) => {
      const fileReader = new FileReader()

      fileReader.onloadend = () => {
        dispatch({
          type: 'crop.start',
          payload: {
            imageToCrop: fileReader.result as string,
          },
        })
      }

      fileReader.readAsDataURL(e.target.files[0])
    },
    [dispatch]
  )

  return (
    <div>
      <label htmlFor="avatar">
        <Avatar handle={user.handle} src={state.avatarUrl} />
      </label>
      <input type="file" id="avatar" onChange={handleFileAttach} />
    </div>
  )
}
