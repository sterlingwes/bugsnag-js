/*
* Automatically notifies Bugsnag when React Native's global error handler is called
*/

module.exports = {
  init: (client, ErrorUtils = global.ErrorUtils) => {
    if (!client._config.autoDetectErrors) return
    if (!ErrorUtils) {
      client._logger.warn('ErrorUtils is not defined. Can’t attach a global error handler.')
      return
    }
    const prev = ErrorUtils.getGlobalHandler()

    ErrorUtils.setGlobalHandler((error, isFatal) => {
      const event = client.BugsnagEvent.create(error, true, {
        severity: 'error',
        unhandled: true,
        severityReason: { type: 'unhandledException' }
      }, 'ErrorUtils globalHandler', 1)
      event.attemptImmediateDelivery = false
      client._notify(event, () => {}, () => {
        if (typeof prev === 'function') prev(error, isFatal)
      })
    })
  }
}
