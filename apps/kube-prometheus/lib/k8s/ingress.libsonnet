local k = import "k.libsonnet";
local n = k.networking.v1;

local newIngress(
            name,
            namespace,
            host,
            className='nginx',
            path='/',
            pathType='ImplementationSpecific',
            backendName=name,
            backendPort,
            issuer='',
            clusterIssuer='',
            tlsSecret=name + '-tls-ingress') = {

         ingressRuleFor::
            n.ingressRule.withHost(host) +
            n.ingressRule.http.withPaths([
            n.httpIngressPath.withPath(path) +
            n.httpIngressPath.withPathType(pathType) +
            n.httpIngressPath.backend.service.withName(backendName) +
            ( if std.isNumber(backendPort) then
                n.httpIngressPath.backend.service.port.withNumber(backendPort)
              else {}
            ) +
            ( if std.isString(backendPort) then
                n.httpIngressPath.backend.service.port.withName(backendPort)
              else {}
            ),
            ]),

        ingressTLSFor::
            ( if issuer != '' || clusterIssuer != '' then
                // n.ingress.metadata.withAnnotationsMixin({
                //     'cert-manager.io/issuer': issuer }) +
                n.ingressTLS.withHosts(host) +
                n.ingressTLS.withSecretName(tlsSecret)
              else {}
            ),

        ingressFor:
            n.ingress.new(name) +
            n.ingress.metadata.withNamespace(namespace) +
            n.ingress.spec.withIngressClassName(className) +
            n.ingress.spec.withRules([self.ingressRuleFor]) +
            ( if self.ingressTLSFor != null then
                n.ingress.spec.withTls(self.ingressTLSFor)
              else {}
            ) +
            ( if issuer != '' then
                n.ingress.metadata.withAnnotationsMixin({
                    'cert-manager.io/issuer': issuer
                })
              else {}
            ) +
            ( if clusterIssuer != '' then
                n.ingress.metadata.withAnnotationsMixin({
                    'cert-manager.io/cluster-issuer': clusterIssuer
                })
              else {}
            ),
    };

{
  newIngress:: newIngress
}
