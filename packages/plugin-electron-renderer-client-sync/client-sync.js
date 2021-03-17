module.exports = (BugsnagIpcRenderer = window.__bugsnag_ipc__) => ({
  load: async (client) => {
    client.addOnBreadcrumb(breadcrumb => {
      try {
        BugsnagIpcRenderer.leaveBreadcrumb(breadcrumb)
      } catch (e) {
        client._logger.error(e)
      }
    }, true)

    const origSetUser = client.setUser
    client.setUser = function (...args) {
      const ret = origSetUser.apply(this, args)
      try {
        BugsnagIpcRenderer.updateUser(client.getUser())
      } catch (e) {
        client._logger.error(e)
      }
      return ret
    }

    const origSetContext = client.setContext
    client.setContext = function (...args) {
      const ret = origSetContext.apply(this, args)
      try {
        BugsnagIpcRenderer.updateContext(client.getContext())
      } catch (e) {
        client._logger.error(e)
      }
      return ret
    }

    const origAddMetadata = client.addMetadata
    client.addMetadata = function (...args) {
      const ret = origAddMetadata.apply(this, args)
      try {
        const [section] = args
        BugsnagIpcRenderer.updateMetadata(section, client.getMetadata(section))
      } catch (e) {
        client._logger.error(e)
      }
      return ret
    }

    const origClearMetadata = client.clearMetadata
    client.clearMetadata = function (...args) {
      const ret = origClearMetadata.apply(this, args)
      try {
        const [section] = args
        BugsnagIpcRenderer.updateMetadata(section, client.getMetadata(section))
      } catch (e) {
        client._logger.error(e)
      }
      return ret
    }

    BugsnagIpcRenderer.listen((event, change) => {
      switch (change.type) {
        case 'ContextUpdate':
          client._context = change.payload.context
          break
        case 'UserUpdate':
          client._user = change.payload.user
          break
        case 'MetadataUpdate':
          client._metadata[change.payload.section] = change.payload.values
      }
    })
  }
})
