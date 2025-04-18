locals {
  stacks = [for i in range(1, 500) : {
    name        = "Kubernetes Cluster ${i}"
    description = "Provisions a Kubernetes cluster"
    branch      = "master"
    repository  = "addressbook"
  }]

  stacks2 = [for i in range(1, 500) : {
    name        = "Other Cluster ${i}"
    description = "Provisions a Kubernetes cluster"
    branch      = "master"
    repository  = "addressbook"
  }]
}

resource "spacelift_stack" "k8s_cluster" {
  for_each         = { for idx, stack in local.stacks : idx => stack }
  name             = each.value.name
  description      = each.value.description
  branch           = each.value.branch
  repository       = each.value.repository

  github_enterprise {
    namespace = "Daniellem97" # Set this to your actual GitHub Enterprise org/user
  }
}

resource "spacelift_run" "this" {
  for_each = { for idx, stack in local.stacks : idx => stack }

  stack_id = spacelift_stack.k8s_cluster[each.key].id

  keepers = {
    branch = spacelift_stack.k8s_cluster[each.key].branch
  }

  depends_on = [spacelift_stack.k8s_cluster]
}

resource "spacelift_stack" "different_cluster" {
  for_each         = { for idx, stack in local.stacks2 : idx => stack }
  name             = each.value.name
  description      = each.value.description
  branch           = each.value.branch
  repository       = each.value.repository

  github_enterprise {
    namespace = "Daniellem97"
  }
}

resource "spacelift_run" "other" {
  for_each = { for idx, stack in local.stacks2 : idx => stack }

  stack_id = spacelift_stack.different_cluster[each.key].id

  keepers = {
    branch = spacelift_stack.different_cluster[each.key].branch
  }

  depends_on = [spacelift_stack.different_cluster]
}
