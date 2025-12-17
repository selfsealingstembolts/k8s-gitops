local k = import "github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet";
local grafana_operator = import "grafana-operator-libsonnet/5.6/main.libsonnet";


local kubernetesMixin =
  (import 'kubernetes-mixin/mixin.libsonnet') +
  {
    _config+:: {
      showMultiCluster: true,
      grafanaDashboard: {
        allowCrossNamespaceImport: true,
        datasources: [
          { datasourceName: "VictoriaMetrics", inputName: "DS_PROMETHEUS" }
        ],
        folder: "Kubernetes",
        instanceSelector: {
          matchLabels: {
            dashboards: "grafana"
          },
        },
      },
    },

    dashboards: $.grafanaDashboards,
    rules: $.prometheusRules,
    alerts: $.prometheusAlerts,
  };

local configMaps(name, resource) = {
  local configMap = k.core.v1.configMap,

  cm: configMap.new(name, std.manifestJson(resource)),
};

local grafanaDashboards(mixin) = {
  local dashboard = grafana_operator.grafana.v1beta1.grafanaDashboard,

  [ name ]:
    local newName = std.strReplace(name, '.json', '');
    dashboard.new(newName)
    + dashboard.spec.withJson(std.manifestJson(mixin.dashboards[name]))
    for name in std.objectFields(mixin.dashboards)
};

local prometheusRules(mixin) = {
  local rule = prometheus_operator.monitoring.v1.prometheusRule

  [ name ]:
    rule.new(name)
    + rule.spec.withJson(std.manifestJson(mixin.dashboards[name]))
    for name in std.objectFields(mixin.dashboards)
};


{ ['dashboards-kubernetesMixin']: grafanaDashboards(kubernetesMixin) }
