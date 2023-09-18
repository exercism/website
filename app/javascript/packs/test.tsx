import React from 'react'
import { initReact } from '@/utils/react-bootloader'
import { LoadingOverlay } from '../components/test/LoadingOverlay'

// Add all react components here.
// Each should map 1-1 to a component in app/helpers/components
initReact({
  'test-loading-overlay': (data: any) => <LoadingOverlay url={data.url} />,
})
