locals {
  custom_roles_indexed          = [for index, item in var.custom_roles_instance_profile != null ? var.custom_roles_instance_profile : [] : merge(item, { index = index })]
  attach_instance_profile       = [for item in local.custom_roles_indexed : item if item.attach_instance]
  roles_exist_indexed           = [for index, item in var.existing_role_names != null ? var.existing_role_names : [] : merge(item, { index = index })]
  attach_instance_profile_exist = [for item in local.roles_exist_indexed : item if item.attach_instance]

  tags_user = {
    "Name"    = var.user_name
    "tf-user" = var.user_name
    "tf-ou"   = var.ou_name
  }
}

### User ###
resource "aws_iam_user" "create_user" {
  count = !var.only_create_group ? 1 : 0

  name = var.user_name
  tags = merge(var.tags, var.use_tags_default ? local.tags_user : {})
}

resource "aws_iam_user_login_profile" "create_login_console_access" {
  count = (var.allow_console_access && !var.only_create_group) ? 1 : 0

  user                    = aws_iam_user.create_user[0].name
  password_reset_required = var.password_reset_required
}

resource "aws_iam_access_key" "create_access_key" {
  count = (var.make_credentials && !var.only_create_group) ? 1 : 0

  user = aws_iam_user.create_user[0].name
}

### Custom Policies ###
resource "aws_iam_policy" "create_custom_policies" {
  count = length(var.custom_policies)

  name        = try(var.custom_policies[count.index].name, null)
  path        = try(var.custom_policies[count.index].path, null)
  description = try(var.custom_policies[count.index].description, null)
  policy      = try(jsonencode(var.custom_policies[count.index].policy), null)
  tags        = try(var.custom_policies[count.index].tags, {})
}

resource "aws_iam_user_policy_attachment" "create_attach_custom_policies_on_user" {
  count = !var.only_create_group ? length(aws_iam_policy.create_custom_policies) : 0

  user       = aws_iam_user.create_user[0].name
  policy_arn = aws_iam_policy.create_custom_policies[count.index].arn
}

data "aws_iam_policy" "data_existing_policies" {
  count = length(var.existing_policy_names)

  name = var.existing_policy_names[count.index].name
}

resource "aws_iam_policy_attachment" "create_attach_policies_exist_on_user" {
  count = !var.only_create_group ? length(data.aws_iam_policy.data_existing_policies) : 0

  name       = "${var.user_name}-attach-policy-${data.aws_iam_policy.data_existing_policies[count.index].name}"
  users      = [aws_iam_user.create_user[0].name]
  policy_arn = data.aws_iam_policy.data_existing_policies[count.index].arn
}

### Attach User to Groups ###
resource "aws_iam_group_membership" "create_attach_user_on_group" {
  count = !var.only_create_group ? length(var.groups) : 0

  name  = "${var.user_name}-member-group-${var.groups[count.index].name}"
  users = [aws_iam_user.create_user[0].name]
  group = var.groups[count.index].name
}

### Exports ###
resource "null_resource" "export_credentials" {
  count = (var.make_credentials && var.path_export_credentials != null) ? 1 : 0

  provisioner "local-exec" {
    command = "echo User: ${var.user_name} >> ${var.path_export_credentials}/${var.user_name}.txt && echo Access Key ID: ${aws_iam_access_key.create_access_key[0].id} >> ${var.path_export_credentials}/${var.user_name}.txt && echo Secret Access Key: ${aws_iam_access_key.create_access_key[0].secret} >> ${var.path_export_credentials}/${var.user_name}.txt"
  }

  depends_on = [
    aws_iam_access_key.create_access_key
  ]
}

resource "null_resource" "export_password" {
  count = (var.allow_console_access && var.path_export_credentials != null) ? 1 : 0

  provisioner "local-exec" {
    command = "echo Password: ${aws_iam_user_login_profile.create_login_console_access[0].password} >> ${var.path_export_credentials}/${var.user_name}.txt"
  }

  depends_on = [
    aws_iam_user_login_profile.create_login_console_access
  ]
}

### Roles Instance Profile ###
resource "aws_iam_role" "create_custom_roles_instance_profile" {
  count = !var.only_create_group ? length(var.custom_roles_instance_profile) : 0

  name               = var.custom_roles_instance_profile[count.index].name
  assume_role_policy = jsonencode(var.custom_roles_instance_profile[count.index].policy)
  tags               = try(var.custom_roles_instance_profile[count.index].tags, {})
}

resource "aws_iam_instance_profile" "create_attach_custom_roles_instance_profile" {
  count = !var.only_create_group ? length(local.attach_instance_profile) : 0

  name = "${var.user_name}-attach-instance-profile-${aws_iam_role.create_custom_roles_instance_profile[local.attach_instance_profile[count.index].index].name}"
  role = aws_iam_role.create_custom_roles_instance_profile[local.attach_instance_profile[count.index].index].name
  tags = try(local.attach_instance_profile[count.index].tags, {})
}

data "aws_iam_role" "data_existing_roles" {
  count = !var.only_create_group ? length(local.attach_instance_profile_exist) : 0

  name = var.existing_role_names[count.index].name
}

resource "aws_iam_instance_profile" "create_attach_custom_roles_exist_instance_profile" {
  count = !var.only_create_group ? length(local.attach_instance_profile_exist) : 0

  name = "${var.user_name}-attach-instance-profile-${data.aws_iam_role.data_existing_roles[local.attach_instance_profile_exist[count.index].index].name}"
  role = data.aws_iam_role.data_existing_roles[local.attach_instance_profile_exist[count.index].index].name
}

### Creation Groups ###
resource "aws_iam_group" "create_group" {
  count = (var.only_create_group && var.group_name != null) ? 1 : 0

  name = var.group_name
}

resource "aws_iam_group_policy_attachment" "create_attach_custom_policies_on_group" {
  count = var.only_create_group ? length(aws_iam_policy.create_custom_policies) : 0

  group      = aws_iam_group.create_group[0].name
  policy_arn = aws_iam_policy.create_custom_policies[count.index].arn
}

resource "aws_iam_group_policy_attachment" "create_attach_policies_exist_on_group" {
  count = var.only_create_group ? length(data.aws_iam_policy.data_existing_policies) : 0

  group      = aws_iam_group.create_group[0].name
  policy_arn = data.aws_iam_policy.data_existing_policies[count.index].arn
}
