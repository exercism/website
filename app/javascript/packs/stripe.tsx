import React from 'react'
import { initReact } from '../utils/react-bootloader.jsx'

import '../../css/pages/editor'
import '../../css/modals/editor-hints'

import { Assignment, Submission } from '../components/editor/types'
import { Form as StripeForm } from '../components/stripe/Form'

import { camelizeKeys } from 'humps'
function camelizeKeysAs<T>(object: any): T {
  return (camelizeKeys(object) as unknown) as T
}

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'stripe-form': (data: any) => <StripeForm />,
})
