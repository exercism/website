import React, { useState, useCallback } from 'react'
import { Icon } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { useSettingsMutation } from './useSettingsMutation'
import { FormMessage } from './FormMessage'
import { FauxInputWithValidation } from './inputs/FauxInputWithValidation'
import { InputWithValidation } from './inputs/InputWithValidation'
import { createMaxLengthAttributes } from './useInvalidField'
import { SeniorityLevel } from '../modals/welcome-modal/WelcomeModal'
import { SingleSelect } from '../common/SingleSelect'

type User = {
  name: string
  location: string
  bio: string
  seniority: SeniorityLevel
}

type Profile = {
  twitter: string
  github: string
  linkedin: string
}

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to save profile')

export default function ProfileForm({
  defaultUser,
  defaultProfile,
  links,
}: {
  defaultUser: User
  defaultProfile: Profile | null
  links: Links
}): JSX.Element {
  const [user, setUser] = useState<User>(defaultUser)
  const [profile, setProfile] = useState<Profile | null>(defaultProfile)

  const { mutation, status, error } = useSettingsMutation<{
    user: User
    profile: Profile | null
  }>({
    endpoint: links.update,
    method: 'PATCH',
    body: { user: user, profile: profile },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <form data-turbo="false" onSubmit={handleSubmit}>
      <h2>Profile</h2>
      <div className="details">
        <div className="name field">
          <label htmlFor="user_name" className="label">
            Name
          </label>
          <InputWithValidation
            id="user_name"
            value={user.name || ''}
            onChange={(e) => setUser({ ...user, name: e.target.value })}
            required
            {...createMaxLengthAttributes('Name', 255)}
          />
        </div>
        <div className="location field">
          <label htmlFor="user_location" className="label">
            Location
          </label>
          <FauxInputWithValidation
            id="user_location"
            value={user.location || ''}
            onChange={(e) => setUser({ ...user, location: e.target.value })}
            icon="location"
            {...createMaxLengthAttributes('Location', 255)}
          />
        </div>
      </div>
      <div className="bio field">
        <label htmlFor="user_bio" className="label">
          Bio
        </label>
        <textarea
          id="user_bio"
          value={user.bio || ''}
          onChange={(e) => setUser({ ...user, bio: e.target.value })}
        />
        <div className="instructions">
          Tell the world about you 🌎. Emojis encouraged!
        </div>
      </div>

      <div className="seniority field">
        <label htmlFor="user_seniority" className="label">
          Seniority
        </label>
        <SenioritySelect
          value={user.seniority}
          setValue={(value) => setUser({ ...user, seniority: value })}
        />
      </div>

      {profile ? (
        <div className="pt-20 mt-24 border-t-1 border-borderColor6">
          <h2>Your social accounts</h2>
          <div className="field">
            <label htmlFor="profile_github" className="label">
              Github (Handle)
            </label>
            <InputWithValidation
              id="profile_github"
              placeholder="Your GitHub handle"
              value={profile.github || ''}
              onChange={(e) =>
                setProfile({ ...profile, github: e.target.value })
              }
              {...createMaxLengthAttributes('GitHub handle', 190)}
            />
          </div>
          <div className="field">
            <label htmlFor="profile_twitter" className="label">
              Twitter (Handle)
            </label>

            <InputWithValidation
              id="profile_twitter"
              placeholder="Your Twitter handle"
              value={profile.twitter || ''}
              onChange={(e) =>
                setProfile({ ...profile, twitter: e.target.value })
              }
              {...createMaxLengthAttributes('Twitter handle', 190)}
            />
          </div>
          <div className="field">
            <label htmlFor="profile_linkedin" className="label">
              LinkedIn (Full URL)
            </label>
            <input
              type="text"
              id="profile_linkedin"
              placeholder="Your LinkedIn profile url"
              value={profile.linkedin || ''}
              onChange={(e) =>
                setProfile({ ...profile, linkedin: e.target.value })
              }
            />
          </div>
        </div>
      ) : null}
      <div className="form-footer">
        <FormButton status={status} className="btn-primary btn-m">
          Save profile data
        </FormButton>
        <FormMessage
          status={status}
          defaultError={DEFAULT_ERROR}
          error={error}
          SuccessMessage={SuccessMessage}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your profile has been saved
    </div>
  )
}

function OptionComponent({ option }: { option: SeniorityLevel }): JSX.Element {
  switch (option) {
    case 'absolute_beginner':
      return <div>Absolute Beginner</div>
    case 'beginner':
      return <div>Beginner</div>
    case 'junior':
      return <div>Junior Developer</div>
    case 'mid':
      return <div>Mid-level Developer</div>
    case 'senior':
      return <div>Senior Developer</div>
  }
}

function SenioritySelect({
  value,
  setValue,
}: {
  value: SeniorityLevel
  setValue: (value: SeniorityLevel) => void
}): JSX.Element {
  return (
    <SingleSelect<SeniorityLevel>
      className="w-[250px]"
      options={['absolute_beginner', 'beginner', 'junior', 'mid', 'senior']}
      value={value}
      setValue={setValue}
      SelectedComponent={OptionComponent}
      OptionComponent={OptionComponent}
    />
  )
}
