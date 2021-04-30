# Script criado por Guilherme Matheus em 15/01/2021
# Referencia da API retirada do link oficial https://docs.microsoft.com/en-us/powershell/module/azuread/?view=azureadps-2.0
# Para funcionar, é necessario instalar alguns módulos, link: https://docs.microsoft.com/pt-br/powershell/azure/azurerm/install-azurerm-ps?view=azurermps-6.13.0

# Para executar o script sem concordar com a politica de execução
Set-ExecutionPolicy Bypass -Scope Process

# Importa os modulos do Azure
Import-Module AzureRM
Import-Module AzureAD

# Dados da conta e do Azure para poder acessar
$PBIAdminUPN = “userbi@vivest.com.br”
$PBIAdminPW = “Law70638”
$MyOrgTenantID = “8def9a7d-e13f-475b-bd57-f27619723591”
$MyOrgBIAppID = “84e116a4-bfc9-4940-bbdb-c0d3fc94aa9a”
$MyOrgBIThumbprint = “E24DF521C12DEDF98752A90A0FA47DD8D3589C9D”


#2. Executa a credencial de acordo com o login, senha e tenant ID acima
$SecPasswd = ConvertTo-SecureString $PBIAdminPW -AsPlainText -Force

$myCred = New-Object System.Management.Automation.PSCredential($PBIAdminUPN,$SecPasswd)

Connect-AzureAD -TenantId “8def9a7d-e13f-475b-bd57-f27619723591” -Credential $myCred

#3. Define o diretório e o nome do arquivo que será exportado o arquivo CSV
$RetrieveDate = Get-Date 
$BasePath = "D:\BI_Processos\PowerShell\Azure\"
$UserPBIProLicensesCSV = $BasePath + "I_BI_PBILICENCASPRO.csv"

#4. Obtem os usuarios das licenças

$ADUsers = Get-AzureADUser -All $true | Select-Object ObjectId, ObjectType, CompanyName, Department, DisplayName, JobTitle, Mail, Mobile, `
            SipProxyAddress, TelephoneNumber, UserPrincipalName, UserType, @{Name="Date Retrieved";Expression={$RetrieveDate}}

<#
See MS Licensing Service Plan reference: 
https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/licensing-service-plan-reference
#>
# Service Plan ID referente as licenças PRO do Power BI
$PBIProServicePlanID = "70d33638-9c74-4d01-bfd3-562de28bd4ba"

# Recupere e exporte usuários com licenças profissionais com base no Service Plan ID do Power BI Pro ($PBIProServicePlanID)
# Cada linha representa um plano de serviço para um usuário específico. Este detalhe da licença é filtrado apenas para a ID do plano de serviço do Power BI Pro.
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

$ProUsers = $UserLicenseDetail | Where-Object {$_.ServicePlanId -eq $PBIProServicePlanID}

#Get-AzureADUserLicenseDetail -ObjectId $UserObjectID | Get-Member
#Get-AzureADSubscribedSku | Get-Member
#Get-AzureADUser | Get-Member

$ProUsers | Export-Csv $UserPBIProLicensesCSV -force -notypeinformation -Encoding UTF8