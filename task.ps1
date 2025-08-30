$location = "uksouth"
$resourceGroupName = "mate-azure-task-16"

$virtualNetworkName = "todoapp"
$vnetAddressPrefix = "10.20.30.0/24"
$webSubnetName = "webservers"
$webSubnetIpRange = "10.20.30.0/26"
$dbSubnetName = "database"
$dbSubnetIpRange = "10.20.30.64/26"
$mngSubnetName = "management"
$mngSubnetIpRange = "10.20.30.128/26"


Write-Host "Creating a resource group $resourceGroupName ..."
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Host "Creating web network security group..."
$webRule = New-AzNetworkSecurityRuleConfig `
            -Name web-allow-http-https-rule `
            -Description "Allow HTTP and HTTPS" `
            -Access Allow `
            -Protocol Tcp `
            -Direction Inbound `
            -Priority 100 `
            -SourceAddressPrefix Internet `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange 80,443

$webSubnetNsg = New-AzNetworkSecurityGroup `
                -ResourceGroupName $resourceGroupName `
                -Location $location `
                -Name $webSubnetName `
                -SecurityRules $webRule

Write-Host "Creating mngSubnet network security group..."
$mngRule = New-AzNetworkSecurityRuleConfig `
            -Name mng-allow-ssh-rule `
            -Description "Allow SSH" `
            -Access Allow `
            -Protocol Tcp `
            -Direction Inbound `
            -Priority 100 `
            -SourceAddressPrefix Internet `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange 22

$mngSubnetNsg = New-AzNetworkSecurityGroup `
                -ResourceGroupName $resourceGroupName `
                -Location $location `
                -Name $mngSubnetName `
                -SecurityRules $mngRule

Write-Host "Creating dbSubnet network security group..."
$dbSubnetNsg = New-AzNetworkSecurityGroup `
                -ResourceGroupName $resourceGroupName `
                -Location $location `
                -Name $dbSubnetName `

Write-Host "Creating a virtual network ..."
$webSubnet = New-AzVirtualNetworkSubnetConfig -Name $webSubnetName -AddressPrefix $webSubnetIpRange -NetworkSecurityGroup $webSubnetNsg
$dbSubnet = New-AzVirtualNetworkSubnetConfig -Name $dbSubnetName -AddressPrefix $dbSubnetIpRange -NetworkSecurityGroup $dbSubnetNsg
$mngSubnet = New-AzVirtualNetworkSubnetConfig -Name $mngSubnetName -AddressPrefix $mngSubnetIpRange -NetworkSecurityGroup $mngSubnetNsg
New-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $webSubnet,$dbSubnet,$mngSubnet
