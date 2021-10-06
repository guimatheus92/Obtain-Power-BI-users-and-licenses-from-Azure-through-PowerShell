# --------------------------------------------------------------------------------------#
# Title: Get licences from Azure
# Author: Guilherme Matheus
# Date: Script created on 18.07.2021
# Script and data info: This script can get all licenses available on Azure
# --------------------------------------------------------------------------------------#

# Reference taken from the official link https://docs.microsoft.com/en-us/powershell/module/azuread/?view=azureadps-2.0
# To work, it is necessary to install some modules, link: https://docs.microsoft.com/pt-br/powershell/azure/azurerm/install-azurerm-ps?view=azurermps-6.13.0

# To execute the script without agreeing with the execution policy
Set-ExecutionPolicy Bypass -Scope Process

# Imports Azure modules
Import-Module AzureRM
Import-Module AzureAD

# Account and Azure data to be able to access
$PBIAdminUPN = “youremail@email.com.br”
$PBIAdminPW = “yourpassword”
$MyOrgTenantID = “your tenant”
$MyOrgBIAppID = “your ID from your Azure app”
$MyOrgBIThumbprint = “thumbprint id”

# Run the credential according to the login, password and tenant ID above
$SecPasswd = ConvertTo-SecureString $PBIAdminPW -AsPlainText -Force

$myCred = New-Object System.Management.Automation.PSCredential($PBIAdminUPN,$SecPasswd)

Connect-AzureAD -TenantId “your Azure tenant” -Credential $myCred

# Defines the directory and name of the file to be exported to the CSV file
$RetrieveDate = Get-Date 
$BasePath = "D:\Azure\"
$OrgO365LicensesCSV = $BasePath + "BI_AzureLicenses.csv"

#https://docs.microsoft.com/en-us/office365/enterprise/powershell/view-licenses-and-services-with-office-365-powershell
$OrgO365Licenses = Get-AzureADSubscribedSku | Select-Object SkuID, SkuPartNumber,CapabilityStatus, ConsumedUnits -ExpandProperty PrepaidUnits | `
    Select-Object SkuID,SkuPartNumber,CapabilityStatus,ConsumedUnits,Enabled,Suspended,Warning, @{Name="Retrieve Date";Expression={$RetrieveDate}} 

$OrgO365Licenses | Export-Csv $OrgO365LicensesCSV -force -notypeinformation -Encoding UTF8
