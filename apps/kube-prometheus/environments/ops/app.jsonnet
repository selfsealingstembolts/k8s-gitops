local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/pyrra.libsonnet') +
  (import 'kube-prometheus/addons/networkpolicies-disabled.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
        platform: 'kubeadm',
      },
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
  // // Modify NetworkPolicies
  //   grafana+:: {
  //     networkPolicy+: {
  //       spec+: {
  //         ingress: [
  //           super.ingress[0] + {
  //             from+: [
  //               {
  //                 namespaceSelector: {
  //                   matchLabels: {
  //                     'kubernetes.io/metadata.name': 'ingress-nginx',
  //                   },
  //                 },
  //                 podSelector: {
  //                   matchLabels: {
  //                     'app.kubernetes.io/name': 'ingress-nginx',
  //                   },
  //                 },
  //               },
  //             ],
  //           },
  //         ] + super.ingress[1:],
  //       },
  //     },
  //   },
  //   prometheus+:: {
  //     networkPolicy+: {
  //       spec+: {
  //         ingress: [
  //           super.ingress[0] + {
  //             from+: [
  //               {
  //                 podSelector: {
  //                   matchLabels: {
  //                     'app.kubernetes.io/part-of': 'kube-prometheus',
  //                   },
  //                 },
  //               },
  //             ],
  //           },
  //         ] + super.ingress[1:],
  //       },
  //     },
  //   },
  };


local ingress =
  (import 'k8s/ingress.libsonnet') +
  {
    grafana:
      self.newIngress(
              name='grafana',
              namespace=kp.values.common.namespace,
              host='grafana.k8s.example.com',
              backendPort='http',
              clusterIssuer='vault-issuer'
      )
  };


{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// { 'setup/pyrra-slo-CustomResourceDefinition': kp.pyrra.crd } +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { ['pyrra-' + name]: kp.pyrra[name] for name in std.objectFields(kp.pyrra) if name != 'crd' } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
// Ingress creation
{ [name]: ingress[name] for name in std.objectFields(ingress) }
