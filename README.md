# Get Power BI users and licenses from Azure through PowerShell script

A document repository can also be found in my profile article at [Medium](https://guimatheus92.medium.com/obtain-power-bi-users-and-licenses-from-azure-through-powershell-7f78bb4c4e21 "Medium").

------------

The first step is to install Azure modules on PowerShell:
```shell
 Install-Module -Name AzureRM -Force
 Install-Module -Name AzureAD -Force
```

The second step is to change your Azure connections:
```shell
# Account and Azure data to be able to access
$PBIAdminUPN = “youremail@email.com.br”
$PBIAdminPW = “yourpassword”
$MyOrgTenantID = “your tenant”
$MyOrgBIAppID = “your ID from your Azure app”
$MyOrgBIThumbprint = “thumbprint id
```

If you want, you can change the folder where you want to download the CSV files
```shell
$BasePath = "D:\Azure\"
```
