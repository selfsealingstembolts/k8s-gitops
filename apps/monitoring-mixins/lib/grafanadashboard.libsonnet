{
  grafanaDashboardFromJSON: {
    new(_config, name, json): {
      apiVersion: 'grafana.integreatly.org/v1beta1',
      kind: 'GrafanaDashboard',
      metadata: {
        name: name,
      },
      spec: {
        allowCrossNamespaceImport: _config.allowCrossNamespaceImport,
        datasources: _config.datasources,
        folder: _config.folder,
        instanceSelector: {
          matchLabels: _config.instanceSelector.matchLabels,
        },
        // envs: _config.envs,
        json: std.manifestJson(json),
      },
    },
  },
}
