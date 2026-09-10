export class ClientSideRunnerError extends Error {
  constructor(message?: string) {
    super(message)
    Object.setPrototypeOf(this, new.target.prototype)
  }
}

/** The page is not cross-origin isolated, so the kernel cannot run at all. */
export class UnsupportedError extends ClientSideRunnerError {}

/** A run overstayed the language's timeout and its worker was killed. */
export class TimeoutError extends ClientSideRunnerError {}

/** The run was cancelled before it could finish. */
export class AbortedRunError extends ClientSideRunnerError {}

/** The kernel could not be loaded or booted. */
export class KernelError extends ClientSideRunnerError {}
