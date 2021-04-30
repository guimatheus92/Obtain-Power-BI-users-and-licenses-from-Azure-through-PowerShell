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
$OrgO365LicensesCSV = $BasePath + "I_BI_AZURELICENCAS.csv"

#https://docs.microsoft.com/en-us/office365/enterprise/powershell/view-licenses-and-services-with-office-365-powershell
$OrgO365Licenses = Get-AzureADSubscribedSku | Select-Object SkuID, SkuPartNumber,CapabilityStatus, ConsumedUnits -ExpandProperty PrepaidUnits | `
    Select-Object SkuID,SkuPartNumber,CapabilityStatus,ConsumedUnits,Enabled,Suspended,Warning, @{Name="Retrieve Date";Expression={$RetrieveDate}} 

$OrgO365Licenses | Export-Csv $OrgO365LicensesCSV -force -notypeinformation -Encoding UTF8