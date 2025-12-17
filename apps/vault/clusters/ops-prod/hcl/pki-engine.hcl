# Enable secrets engine
path "sys/mounts/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# List enabled secrets engine
path "sys/mounts" {
  capabilities = [ "read", "list" ]
}

# Work with pki secrets engine
path "pki*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

path "pki_int/sign/k8s-example-com" {
  capabilities = [ "create", "update"]
}

path "pki_int/issue/k8s-example-com" {
  capabilities = [ "create" ]
}
