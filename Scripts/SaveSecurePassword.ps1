﻿read-host -prompt "Enter password to be encrypted in O365SecurePassword.txt " -assecurestring | convertfrom-securestring | out-file C:\PowerShell\SecureStrings\O365SecurePassword.txt