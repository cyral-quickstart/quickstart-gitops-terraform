# Cyral GitOps with GitHub Actions and Terraform Cloud

This is suitable for teams who want to manage their Cyral configuration using a
GitOps approach, even if they don't currently use Terraform. This provides a
very simple Terraform setup that uses [GitHub Actions](gha) as a CI/CD pipeline
and [Terraform Cloud][tfcloud] for Terraform state management.

The GitHub Actions pipelines are defined in the
[`.github/workflows/terraform.yaml`](.github/workflows/terraform.yaml) file.

For a more general overview on managing Cyral with GitOps, please see our public
documentation: https://cyral.com/docs/v3.0/how-to/gitops

## Prerequisites

Please see the general prerequisites defined in the top-level
[README](../README.md), as they apply to this example as well.

The specific workflow automation in this quick start is powered by
[GitHub Actions][gha] (see [terraform.yaml](.github/workflows/terraform.yaml)),
although the general principles and steps should apply to any CI/CD automation
platform (GitLab CI/CD, BitBucket Pipelines, CircleCI, etc.).

Additionally, the following prerequisites are required to use the example
automated GitOps workflow with [Terraform Cloud][tfcloud].

* A [Terraform Cloud][tfcloud] account (a free account is fine).
    * A [Terraform Cloud API token][tfcloud-token] - generate this in Terraform
      Cloud User Settings. Click on "Create an API token" and generate an API
      token named "GitHub Actions".

## Setup

1. Copy, update, and commit [`main.tf`](../main.tf) to the root level of your
   repository.
    * This file is the actual Terraform configuration - in includes all the
      resource definitions to create the infrastructure defined in it. See the
      documentation comments in [`main.tf`](../main.tf) for specifics.
2. Copy [`main.tf`](../main.tf) from the root level, and the contents of this
   directory, into a GitHub repository in your GitHub account/organization.
3. Configure the following repository [secrets][ghsec]:
    * **CYRAL_CONTROL_PLANE** - the address of your Cyral control plane, in the
      format `<hostname>:<port>`
    * **CYRAL_CLIENT_ID** - the Cyral API credentials client ID
    * **CYRAL_CLIENT_SECRET** - the Cyral API credentials client secret
    * **TF_API_TOKEN*** - the Terraform Cloud API token, described in the
      previous section.
4. Create and checkout a new branch, e.g. `git checkout -B quickstart_changes`
5. Make the following required change to `main.tf`:
    * Change the `organization` value in the `cloud` block (around line 10) to
      your Terraform Cloud organization.
    * _Optionally_, make any other desired changes, such as providing the
      host/port of a real data repository you wish to track, or changing the
      details of the policy included in the configuration.
6. Create a pull request on your copy of the repository with some changes,
7. Inspect the output of `terraform plan` in the pull request.
8. Merge the pull request to the `main` branch to trigger the `terraform apply`
9. Inspect the Cyral control plane to see that the resources were created by
   Terraform.

[gha]: https://github.com/features/actions

[ghsec]: https://docs.github.com/en/actions/security-guides/encrypted-secrets

[tfcloud]: https://www.terraform.io/cloud-docs

[tfcloud-token]: https://www.terraform.io/cloud-docs/users-teams-organizations/api-tokens
