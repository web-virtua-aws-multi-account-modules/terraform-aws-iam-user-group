# AWS IAM to create user and groups for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a IAM to create user and groups across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of IAM configurations for this module:

- IAM user
- User login profile
- IAM access key
- Policies
- Roles
- Attachments
- IAM group membership
- IAM groups

## Usage exemples

### Creation user with console access and credentials, export file with credentials, using role and policy existing and creation new policy and role to user

```hcl
module "create_user" {
  source = "web-virtua-aws-multi-account-modules/iam-user-group/aws"

  user_name               = "username"
  allow_console_access    = true
  make_credentials        = true
  path_export_credentials = "$PWD/path-to-save"

  custom_policies = [
    {
      name        = "tf-test-policy"
      path        = "/"
      description = "My test policy"

      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:PutMetricFilter",
              "logs:PutRetentionPolicy"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      }
    }
  ]

  custom_roles_instance_profile = [
    {
      name            = "tf-test-role"
      attach_instance = true

      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
              Service = ["sns.amazonaws.com"]
            }
          },
        ]
      }
    }
  ]

  existing_policy_names = [
    {
      name = "AmazonSageMakerFullAccess"
    }
  ]

  existing_role_names = [
    {
      name = "tf-lambda-trust-role"
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Creating group with policies and attaching the policies created and exists

```hcl
module "create_group" {
  source = "web-virtua-aws-multi-account-modules/iam-user-group/aws"
  
  only_create_group = true
  group_name        = "tf-test-group"

  custom_policies = [
    {
      name        = "tf-test-policy-group"
      path        = "/"
      description = "My test policy group"

      policy = {
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:PutMetricFilter",
              "logs:PutRetentionPolicy"
            ]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      }
    }
  ]

  existing_policy_names = [
    {
      name = "AmazonSageMakerFullAccess"
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| region | `string` | `us-east-1` | no | AWS region | `-` |
| custom_policies | `list(object)` | `[]` | no | List of the custom policies | `-` |
| existing_policy_names | `list(object)` | `[]` | no | List of the names to existing policies | `-` |
| custom_roles_instance_profile | `list(object)` | `[]` | no | List of the custom roles to attach instance profile | `-` |
| existing_role_names | `list(object)` | `[]` | no | List of the names to existing roles | `-` |
| groups | `list(object)` | `[]` | no | List of the groups | `-` |
| user_name | `string` | `null` | no | User name | `-` |
| group_name | `string` | `null` | no | Group name | `-` |
| make_credentials | `bool` | `true` | no | If true will make the AWS credentials | `*`false <br> `*`true |
| allow_console_access | `bool` | `false` | no | If true will allow AWS console access | `*`false <br> `*`true |
| password_reset_required | `bool` | `false` | no | If true reset is required | `*`false <br> `*`true |
| path_export_credentials | `string` | `null` | no | xxx | `-` |
| only_create_group | `bool` | `false` | no | If true It's only create resources to groups, policies and attachments| `*`false <br> `*`true |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| tags | `map(any)` | `{}` | no | Tags to resources | `-` |


## Resources

| Name | Type |
|------|------|
| [aws_iam_user.create_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_login_profile.create_login_console_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile) | resource |
| [aws_iam_access_key.create_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_policy.create_custom_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy.html) | resource |
| [aws_iam_user_policy_attachment.create_attach_custom_policies_on_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_policy_attachment.create_attach_policies_exist_on_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_group_membership.create_attach_user_on_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_role.create_custom_roles_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_instance_profile.create_attach_custom_roles_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_group.create_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy_attachment.create_attach_custom_policies_on_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_group_policy_attachment.create_attach_policies_exist_on_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `console_password` | AWS console password |
| `credentials` | Secret key and access key |
| `user` | User information |
| `custom_policies` | Custom policies |
| `attach_user_groups` | Attachment user on groups |
| `custom_roles` | Custom roles |
| `group` | Group |
