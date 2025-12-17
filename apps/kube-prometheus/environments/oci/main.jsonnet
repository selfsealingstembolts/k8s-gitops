local app = (import "./app.jsonnet");

function(name, apiServer, namespace) {
  apiVersion: 'tanka.dev/v1alpha1',
  kind: 'Environment',
  metadata: {
    name: name,
  },
  spec: {
    apiServer: apiServer,
    namespace: namespace,
  },
  data: app,
}
