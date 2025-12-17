local kp =
  (import 'kube-prometheus/main.libsonnet') +
  (import 'ingress.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'https://grafana.k8s.example.com/',
            },
          },
        },
      },
    },
    // Create one ingress object that routes to each individual application
    ingress+:: {
      grafana:
        $.withIngress(
          name='grafana',
          namespace=$._config.namespace,
          host='grafana.k8s.example.com',
          backendPort='http',
          clusterIssuer='vault-issuer'
        )
    },
  };

local ingress = import 'ingress.libsonnet';

{
  ingress+:: {
    grafana:
      ingress.withIngress(
            name='grafana',
            namespace=kp._config.namespace,
            host='grafana.k8s.example.com',
            backendPort='http',
            clusterIssuer='vault-issuer'
      )
  }
}

{ [name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
