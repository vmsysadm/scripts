Function vmclone-init {
    param(
		[Parameter(Mandatory=$true)]$template,
		[Parameter(Mandatory=$true)]$user_data_file,
        	[Parameter(Mandatory=$true)]$name
    )
	$vmhost =  get-vmhost | select -First 1
	$vm = New-VM -Name $name -VM $template -VMHost $vmhost -DiskStorageFormat "thin"
	
	$ovf = Get-VMOvfProperty -VM (Get-VM -Name $name)
	$ovfPropertyChanges = @{}
	foreach ($obj in $ovf) {
		$ovfPropertyChanges.add($obj.id,$obj.value)
	}
	
	$ovfPropertyChanges."hostname" = $name
	$ovfPropertyChanges."instance-id" = get-vm $name | %{(Get-View $_.Id).config.InstanceUuid}
	$user_data_file = Resolve-Path $user_data_file
	$user_data = [Convert]::ToBase64String([IO.File]::ReadAllBytes($user_data_file))
	$ovfPropertyChanges."user-data" = $user_data
	$result = Set-VMOvfProperty -VM (Get-VM -Name $name) -ovfChanges $ovfPropertyChanges
	Start-VM $name
}
