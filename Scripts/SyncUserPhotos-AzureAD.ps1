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