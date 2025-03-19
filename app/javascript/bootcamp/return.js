if (window.location.pathname === '/courses/enrolled') {
  // initialize()
  document.getElementById('pending').classList.add('hidden')
  document.getElementById('success').classList.remove('hidden')
}

async function initialize() {
  const queryString = window.location.search
  const urlParams = new URLSearchParams(queryString)
  const sessionId = urlParams.get('session_id')
  const failurePath = urlParams.get('failure_path')
  if (!sessionId) {
    window.location.replace(failurePath)
    return
  }
  const response = await fetch(
    `/courses/stripe/session-status?session_id=${sessionId}`
  )
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
