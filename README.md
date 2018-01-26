# O365-UserPhoto-PowerShell

These PowerShell scripts will allow you to connect to your Office 365 tenant and download the user profile photos.  Using a stored secure password, the script can be used as part of a scheduled task.

## Prerequisites

### Setup Environment

If you have not previously connected to Office 365 with PowerShell, please follow these setup instructions:  [Connect to Office 365 PowerShell](https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell)

### Install Modules

You can use the [MSOL](https://www.powershellgallery.com/packages/MSOnline/1.1.166.0) (Microsoft Online Data Service) module or the newer [AzureAD](https://www.powershellgallery.com/packages/AzureAD/2.0.0.131) (Azure Active Directory) module.

There are minimal differences to the main PowerShell script to use either one. ([SyncUserPhotos-MSOL](Scripts/SyncUserPhotos-MSOL.ps1) or [SyncUserPhotos-AzureAD](Scripts/SyncUserPhotos-AzureAD.ps1))

## Configuration

### Save Encrypted Password

To automate the execution of the main PowerShell script, it is necessary to store the password in an encrypted file so that the login prompt does not appear.  You can run the [SaveSecurePassword](Scripts/SaveSecurePassword.ps1) PowerShell script to save your password in a directory of your choosing.  The example path is `C:\PowerShell\SecureStrings`.

```powershell
read-host -prompt "Enter password to be encrypted in O365SecurePassword.txt " -assecurestring | convertfrom-securestring | out-file C:\PowerShell\SecureStrings\O365SecurePassword.txt
```

#### Available scripts:

**Folder: [Scripts](Scripts)**

| Script | Description
| :--- | :---
| [SaveSecurePassword](Scripts/SaveSecurePassword.ps1) | Script to save secure password

### Customize main PowerShell script

At this point, you will need to modify the script to meet your local environment.  Below are the items that will need customized:
 1. Set secure password folder\file name in line 2
 2. Set Office 365 user name in line 4
 3. Set export file path for user photos in line 23

```powershell
# Setup security
$O365Pass = cat C:\PowerShell\SecureStrings\O365SecurePassword.txt | convertto-securestring                                                           

$O365Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist "XXXXX@XXXXX.com",$O365Pass 

# Enable Exchange cmdlets
add-pssnapin *exchange* -erroraction SilentlyContinue

# Connect to O365
Import-Module AzureAD

$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Authentication Basic -AllowRedirection -Credential $O365Cred

Import-PSSession $O365Session

Connect-AzureAD -Credential $O365Cred

# Cycle through users that have photos.  Save picture to file.
$objUsers = Get-Mailbox -ResultSize unlimited | Where-Object HasPicture -eq $true
Foreach ($objUser in $objUsers)
{
    $user = Get-UserPhoto $objUser.UserPrincipalName	
    $user.PictureData |Set-Content "C:\PowerShell\Users\$($objUser.UserPrincipalName).jpg" -Encoding byte
}

# Remove PowerShell Session
Remove-PSSession $O365Session
```

#### Available scripts:

**Folder: [Scripts](Scripts)**

| Script | Description
| :--- | :---
| [SyncUserPhotos-MSOL](Scripts/SyncUserPhotos-MSOL.ps1) | Script using MSOL Module
| [SyncUserPhotos-AzureAD](Scripts/SyncUserPhotos-AzureAD.ps1) | Script using AzureAD Module
