# quickstart-gitops-terraform

This quick start demonstrates a simple GitOps workflow which can be used to
configure and manage Cyral using Terraform and
[Cyral's Terraform Provider][cyraltfprov]. The example includes using Terraform
to:

* Track a **data repository**.
* Define a **data map** for the repository's sensitive data.
* Define a **policy** to enforce access to that sensitive data.

The [Cyral Terraform Provider][cyraltfprov] allows you to define the resources
and configuration in your Cyral Control Plane as code using the Terraform's
[configuration language](https://www.terraform.io/language).

Ultimately, this quick start will help you enforce [security as code][1] using
Cyral and Terraform.

## Using this Quick Start

This quickstart demonstrates how to use Terraform alongside a CI/CD platform to
manage Cyral infrastructure as code. Two CI/CD examples are provided in this
quickstart: [GitHub Actions](github) and [GitLab CI/CD](gitlab). Note that while
only these two platforms are demonstrated here, Cyral's GitOps-style workflow
can be used with _any_ CI/CD automation platform (such as GitHub Actions,
GitLab CI/CD, BitBucket Pipelines, CircleCI, etc.).

This quick start can be copied and used in a standalone GitHub or GitLab
repository to take advantage of the automated workflow. Alternatively, if you
just want to play with the Cyral Terraform provider, or have another CI/CD
platform that you want to adapt this workflow to, please feel free to use this
code as a baseline to build from.

### Prerequisites

* A functional Cyral deployment. If you don't have one, please
  [register for a free trial](https://cyral.com/register/)!
* A set of [Cyral API client credentials (client ID and secret)][apicreds].

To generate the API client credentials, go to your Cyral Control Plane and
navigate to "API Client Credentials" on the left-hand navigation bar. Then click
the "+" button to create a new set of credentials, and provide a given name and
set of permissions. For this specific quickstart, the API client used requires
the following permissions:

* View Datamaps
* Modify Policies
* View Sidecars and Repositories
* Modify Sidecars and Repositories

Once the API client is created, the client ID and secret will be displayed on
the screen. Save these values because they will be inaccessible from the Control
Plane later and must be regenerated if lost.

The following prerequisites are optional, but recommended:

* A Cyral sidecar, deployed and functional.
* A database which you want to be protected by the sidecar.

Finally, both the [GitLab](gitlab) and [GitHub](github) examples have their own
prerequisites, so please see the `README` for each example for details.

### Custom Terraform Runner

If you don't want to use the GitHub Actions or GitLab CI/CD workflows, feel free
to run Terraform by hand or in some other task runner / CI/CD engine, (and
optionally remove the Terraform Cloud configuration if desired). The workflow
outlined below is standard enough to run on any CI/CD platform.

## GitOps Workflow

This quickstart presents an example of a simple automated, pull-request driven
GitOps workflow:

![GitOps Workflow using Terraform](./gitops_workflow.svg)

The general principles and steps should apply to any CI/CD automation platform
(GitLab CI/CD, BitBucket Pipelines, CircleCI, etc.).

The workflow starts with a source code repository containing some
[Terraform configuration](main.tf) on a single `main` branch. Any changes made
to the configuration are made on [short-lived feature branches][3]. A
pull-request is created for each feature branch when the change is ready to
be reviewed. At that point, the workflow runs a formatting and validation
checks on the configuration, followed by a `terraform plan`. The results of the
plan are added back to the pull-request as a feedback comment, so developers
can review the output and ensure everything looks good. Once the PR is approved
and merged to the `main` branch, the workflow applies the configuration by
running `terraform apply`. This step _actually_ creates all the resources
defined in the configuration on the Cyral platform.

![PR and Main Workflows](./workflows.svg)

### Terraform State

Note that the [Terraform State][4] file (`terraform.tfstate`) is generated and
stored in [Terraform Cloud][tfcloud] in the [GitHub Actions](github) example,
and on [GitLab's Terraform backend][gltf] for the [GitLab](gitlab) example.
Terraform requires the latest version of this state file when
executing `terraform plan`
and `terraform apply` to ensure accurate results. Each time one of these
commands are run, Terraform pulls the latest state file from the respective
storage and uses it to evaluate the work it needs to do.

You can configure the Terraform state storage however you want when using these
examples. However, we (and HashiCorp themselves) strongly recommend using remote
state management, as opposed to managing the state as a local file. While there
is nothing inherently _wrong_ with the local file option, in most scenarios you
probably don't want to do this and instead opt for a [remote state][5] option.
This will allow better collaboration between developers, as well as more secure
storage of any sensitive information contained within the state file.

## Next Steps

Feel free to use this quick start as a foundation for managing your Cyral
infrastructure and security configuration as code. The Terraform configuration
here can also be combined with any existing Terraform you may have, such as
configuration to stand up resources in AWS, etc. You can take this further by
standing up your cloud resources (such as databases) and protecting them with
Cyral within the same Terraform configuration! Also, you can experiment with the
GitOps workflow, perhaps adding concepts required approvals, etc. It's really
up to your imagination!

Please view the [Cyral documentation](https://cyral.com/docs/) for more details
on how you can use Cyral to protect your data.

## Additional Links

* [Cyral Documentation][cyraldocs]
* [Cyral Terraform Provider][cyraltfprov]
* [Manage Cyral with GitOps][cyralgitops]
* [Automate Terraform (Terraform official documentation)][tf-automation]

[1]: https://cyral.com/white-papers/what-is-security-as-code/

[2]: https://github.com/features/actions

[3]: https://trunkbaseddevelopment.com/short-lived-feature-branches/

[4]: https://www.terraform.io/language/state

[5]: https://www.terraform.io/language/state/remote

[tfcloud]: https://www.terraform.io/cloud-docs

[tfcloud-token]: https://www.terraform.io/cloud-docs/users-teams-organizations/api-tokens

[cyraldocs]: https://cyral.com/docs/

[cyraltfprov]: https://registry.terraform.io/providers/cyralinc/cyral/latest/docs

[tf-automation]: https://learn.hashicorp.com/collections/terraform/automation

[gltf]: https://docs.gitlab.com/ee/user/infrastructure/iac/terraform_state.html

[apicreds]: https://cyral.com/docs/v3.0/api-ref/api-intro

[cyralgitops]: https://cyral.com/docs/v3.0/how-to/gitops
