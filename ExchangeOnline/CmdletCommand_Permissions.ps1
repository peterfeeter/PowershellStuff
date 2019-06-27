$Perms = Get-ManagementRole -Cmdlet Set-MailboxAutoReplyConfiguration
$Perms | foreach {Get-ManagementRoleAssignment -Role $_.Name -Delegating $false | Format-Table -Auto Role,RoleAssigneeType,RoleAssigneeName}