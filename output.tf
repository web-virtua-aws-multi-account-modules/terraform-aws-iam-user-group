output "console_password" {
  description = "AWS console password"
  value       = try(aws_iam_user_login_profile.create_login_console_access[0].password, null)
}

output "credentials" {
  description = "Secret key and access key"
  value       = try(aws_iam_access_key.create_access_key[0], null)
}

output "user" {
  description = "User information"
  value       = try(aws_iam_user.create_user[0], null)
}

output "custom_policies" {
  description = "Custom policies"
  value       = try(aws_iam_policy.create_custom_policies, null)

}

output "attach_user_groups" {
  description = "Attachment user on groups"
  value       = try(aws_iam_group_membership.create_attach_user_on_group)
}

output "custom_roles" {
  description = "Custom roles"
  value       = try(aws_iam_role.create_custom_roles_instance_profile, null)

}

output "group" {
  description = "Group"
  value       = try(aws_iam_group.create_group[0], null)
}
