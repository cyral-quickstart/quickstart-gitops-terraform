# Cyral GitOps with Gitlab CI/CD's Terraform Feature

This is suitable for teams who want to manage their Cyral configuration using a
GitOps approach, even if they don't currently use Terraform. This provides a
very simple Terraform setup that uses [GitLab's Terraform feature](https://docs.gitlab.com/ee/user/infrastructure/iac/).

The GitLab CI/CD pipeline is defined in the [`.gitlab-ci.yml`](.gitlab-ci.yml)
file.

For a more general overview on managing Cyral with GitOps, please see our public
documentation: https://cyral.com/docs/v3.0/how-to/gitops

## Setup

* Create Cyral API access key (Client ID/Secret)
    * https://cyral.com/docs/v3.0/api-ref/api-intro#api-access-key
    * https://registry.terraform.io/providers/cyralinc/cyral/latest/docs#provider-credentials---ui
* Create a new GitLab repository
* Configure GitLab Repository
    * Settings -> Merge Requests
        * Merge checks -> Pipelines must succeed
        * Merge request approvals - Add appropriate approval rule
    * Settings -> CI/CD -> Variables

|Name|Protected|Masked|
|---|---|---|
|TF_VAR_cyral_control_plane|No|No|
|TF_VAR_cyral_client_id|No|No|
|TF_VAR_cyral_client_secret|No|Yes|

* Copy, update, and commit [`main.tf`](../main.tf) to the root level of your
  repository.
    * This file is the actual Terraform configuration - in includes all the
      resource definitions to create the infrastructure defined in it. See the
      documentation comments in [`main.tf`](../main.tf) for specifics.
* Commit [`.gitlab-ci.yaml`](.gitlab-ci.yml) to the root level of your
  repository.
    * This CI file will provide a basic GitOps workflow that will take advantage
      of the GitLab Terraform state management and utilizes the templated CI
      files. It will provide formatting and syntax validation and run a
      Terraform plan for each Merge Request, which is why the variables are not
      marked as Protected. Upon merge a pipeline will run with the last job
      configured as manual, which is the Terraform Apply.

For additional information regarding GitLab's Terraform feature,
see: https://docs.gitlab.com/ee/user/infrastructure/iac/
