Get-MailboxPermission -Identity "AUS Invoices" | Select -Expand User

Remove-MailboxPermission -Identity "AUS Invoices" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All

Remove-MailboxPermission -Identity "EMEA AP Helpdesk" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All
Remove-MailboxPermission -Identity "ICAP SG ACCOUNTS PAYABLE" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All
Remove-MailboxPermission -Identity "NZ Invoices" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All
Remove-MailboxPermission -Identity "SG APHelpdesk" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All
Remove-MailboxPermission -Identity "SG Invoices" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All
Remove-MailboxPermission -Identity "SGInvoicestocode" -User "Antony.Gordon@tpicap.com" -AccessRights FullAccess -InheritanceType All