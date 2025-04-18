locals {
  stacks = [
    for i in range(1, 1001) : {
      name           = "${i <= 500 ? "First" : "Second"} Kubernetes Cluster ${i}"
      description    = "Provisions a Kubernetes cluster"
      branch         = "master"
      repository     = "addressbook"
    }
  ]
}

resource "spacelift_stack" "k8s_cluster" {
  for_each         = { for idx, stack in local.stacks : idx => stack }
  name             = each.value.name
  description      = each.value.description
  branch           = each.value.branch
  repository       = each.value.repository
}

resource "spacelift_run" "this" {
  for_each = { for idx, stack in local.stacks : idx => stack }

  stack_id = spacelift_stack.k8s_cluster[each.key].id

  keepers = {
    branch = spacelift_stack.k8s_cluster[each.key].branch
  }
}
