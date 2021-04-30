# --------------------------------------------------------------------------------------#
# Title: Delete files older than seven days
# Author: Guilherme Matheus
# Date: Script created on 30.04.2021
# Script and data info: This script clean up a folder with files older than 1 week
# --------------------------------------------------------------------------------------#

# Reference taken from the official link https://docs.microsoft.com/en-us/powershell/module/azuread/?view=azureadps-2.0
# To work, it is necessary to install some modules, link: https://docs.microsoft.com/pt-br/powershell/azure/azurerm/install-azurerm-ps?view=azurermps-6.13.0

# To execute the script without agreeing with the execution policy
Set-ExecutionPolicy Bypass -Scope Process

# Imports Azure modules
Import-Module AzureRM
Import-Module AzureAD

# Email and Azure account data to be able to connect
$PBIAdminUPN = “youremail@email.com.br”
$PBIAdminPW = “yourpassword”
$MyOrgTenantID = “your Azure tenant”
$MyOrgBIAppID = “your ID from your Azure app”
$MyOrgBIThumbprint = “thumbprint id”

# Run the credential according to the login, password and tenant ID above
$SecPasswd = ConvertTo-SecureString $PBIAdminPW -AsPlainText -Force

$myCred = New-Object System.Management.Automation.PSCredential($PBIAdminUPN,$SecPasswd)

Connect-AzureAD -TenantId “your Azure tenant” -Credential $myCred

# Defines the directory and name of the file to be exported to the CSV file
$RetrieveDate = Get-Date 
$BasePath = "D:\Azure\"
$UserPBIProLicensesCSV = $BasePath + "PBIFree.csv"

# Get license users
$ADUsers = Get-AzureADUser -All $true | Select-Object ObjectId, ObjectType, CompanyName, Department, DisplayName, JobTitle, Mail, Mobile, `
            SipProxyAddress, TelephoneNumber, UserPrincipalName, UserType, @{Name="Date Retrieved";Expression={$RetrieveDate}}

<#
See MS Licensing Service Plan reference: 
https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
#>
# Service Plan ID for Power BI PRO licenses
$PBIFreeServicePlanID = "70d33638-9c74-4d01-bfd3-562de28bd4ba"

# Retrieve and export users with professional licenses based on the Power BI Free Service Plan ID ($PBIFreeServicePlanID)
# Each line represents a service plan for a specific user. This license detail is filtered only for the Power BI FREE service plan ID.
$UserLicenseDetail = ForEach ($ADUser in $ADUsers)
    {
        $UserObjectID = $ADUser.ObjectId
        $UPN = $ADUser.UserPrincipalName
        $UserName = $ADUser.DisplayName
        $UserDept = $ADUser.Department
        $AccountEnabled = $ADUser.AccountEnabled
        $AssignedTimestamp = $ADUser.AssignedTimestamp
        $CapabilityStatus = $ADUser.CapabilityStatus
        Get-AzureADUserLicenseDetail -ObjectId $UserObjectID -ErrorAction SilentlyContinue | `
        Select-Object ObjectID, SkuPartNumber, @{Name="UserName";Expression={$UserName}},@{Name="UserPrincipalName";Expression={$UPN}}, `
        @{Name="Department";Expression={$UserDept}},@{Name="RetrieveDate";Expression={$RetrieveDate}} -ExpandProperty ServicePlans
    }

$ProUsers = $UserLicenseDetail | Where-Object {$_.ServicePlanId -eq $PBIFreeServicePlanID}

#Get-AzureADUserLicenseDetail -ObjectId $UserObjectID | Get-Member
#Get-AzureADSubscribedSku | Get-Member
#Get-AzureADUser | Get-Member

$ProUsers | Export-Csv $UserPBIProLicensesCSV -force -notypeinformation -Encoding UTF8
