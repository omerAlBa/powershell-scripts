echo '[+] Service Enumaration'
$services = Get-Service

Foreach ( $service in $services ) {

	$regPath = "HKLM:\System\CurrentControlSet\Services\$($service.name)"
	if ( Test-Path $regPath ) {
		echo ""
		echo "###############"
  		echo "Service name -> $($service.name)"
   		$object =  Get-ItemProperty -Path $regpath
		echo "---------------"
		echo $object
	}
}


