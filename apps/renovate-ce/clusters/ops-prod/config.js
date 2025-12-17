module.exports = {
  onboardingConfig: {
    $schema: "https://docs.renovatebot.com/renovate-schema.json",
    extends: [
      "local>renovate-presets/renovate-config:global-default",
    ],
  },

  gitAuthor: "Renovate Bot <renovate@example.com>",
  detectHostRulesFromEnv: true,

  repositoryCache: "enabled",
  persistRepoData: true,

  packageRules: [
    {
      matchDatasources: ["docker"],
      registryUrls: ["https://docker-registry.k8s.example.com"],
    },
  ],
};
