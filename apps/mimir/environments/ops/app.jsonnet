local mimir = import "mimir/mimir.libsonnet";

mimir {
  _config+:: {
    namespace: "monitoring",
    cluster: "ops",
    external_url: "mimir.k8s.example.com",
    usage_stats_enabled: false,

    deployment_mode: 'read-write',

    mimir_write_replicas: 3,
    mimir_read_replicas: 3,
    mimir_backend_replicas: 3,

    // Requirements.
    multi_zone_ingester_enabled: true,
    multi_zone_store_gateway_enabled: true,
    ruler_remote_evaluation_enabled: false,

    // Disable microservices autoscaling.
    autoscaling_querier_enabled: false,
    autoscaling_ruler_querier_enabled: false,

    storage_backend: 's3',
    storage_s3_endpoint: '<path:internal/data/k8s/ops/mimir#s3_endpoint',
    storage_s3_access_key_id: '<path:internal/data/k8s/ops/mimir#s3_access_key_id>',
    storage_s3_secret_access_key: '<path:internal/data/k8s/ops/mimir#s3_secret_access_key>',
    s3BlocksStorageConfig+: {
      'blocks-storage.s3.insecure': true,
    },

    blocks_storage_bucket_name: 'mimir',
    ruler_storage_bucket_name: 'mimir-ruler',

  },
}
