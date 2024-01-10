$accessKey = "AKIAY7SEYN2PGNMGEEFK"
$secretKey = "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"
$region = "us-east-2"
$securityGroupId = "sg-06d20f1c94cf9b730"

# Set the security group details
$protocol = "tcp"
$port = "80" # e.g., 8080

# Fetching your public IP address dynamically
$sourceIP = (Invoke-RestMethod -Uri "https://api.ipify.org?format=text").Trim() + "/32"

# Set the rule description
$description = "Allow incoming traffic on port $port from $sourceIP"

# Set up AWS credentials and region
Set-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey
Set-DefaultAWSRegion -Region $region

# Get the security group
$securityGroup = Get-EC2SecurityGroup -GroupId $securityGroupId

# Check if the rule already exists
$existingRule = $securityGroup.IpPermissions | Where-Object {
    $_.IpProtocol -eq $protocol -and
    $_.FromPort -eq $port -and
    $_.ToPort -eq $port -and
    $_.IpRanges -eq $sourceIP
}

if ($existingRule -eq $null) {
    # Add inbound rule to the security group if it doesn't exist
    $ipPermissionObject = New-Object Amazon.EC2.Model.IpPermission
    $ipPermissionObject.IpProtocol = $protocol
    $ipPermissionObject.FromPort = $port
    $ipPermissionObject.ToPort = $port
    $ipPermissionObject.IpRanges = @($sourceIP)
    
    $securityGroup | Grant-EC2SecurityGroupIngress -IpPermission $ipPermissionObject
    Write-Output "Inbound rule added successfully: $description"
} else {
    Write-Output "The specified rule already exists: $description"
}

# Display your public IP address
Write-Output "Your public IP address: $sourceIP"
