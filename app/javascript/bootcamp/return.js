if (window.location.pathname === '/courses/enrolled') {
  initialize()
}

async function initialize() {
  const queryString = window.location.search
  const urlParams = new URLSearchParams(queryString)
  const sessionId = urlParams.get('session_id')
  const enrollmentUuid = urlParams.get('enrollment_uuid')
  let failurePath = urlParams.get('failure_path')
  if (!failurePath || !failurePath.startsWith('/courses/')) {
    failurePath = '/bootcamp'
  }

  if (!sessionId) {
    window.location.replace(failurePath)
    return
  }
  const response = await fetch(
    `/courses/stripe/session-status?session_id=${sessionId}&enrollment_uuid=${enrollmentUuid}`
  )

  if (!response.ok) {
    window.location.replace(failurePath)
    return
  }

  const session = await response.json()

  if (session.status == 'open') {
    window.location.replace(failurePath)
  } else if (session.status == 'complete') {
    document.getElementById('pending').classList.add('hidden')
    document.getElementById('success').classList.remove('hidden')
    document.getElementById('customer-email').textContent =
      session.customer_email
  }
}
