$WSL_IP = (wsl hostname -I).Trim()
$WSL_HOST_IP = Get-NetAdapter 'vEthernet (WSL)' | Get-NetIPAddress | ?{ $_.AddressFamily -eq 'IPv4' } | Select -ExpandProperty IPAddress

Write-Host "WSL's current IP: " -ForegroundColor Gray -NoNewLine
Write-Host "$WSL_IP" -ForegroundColor Green
Write-Host "WSL host's current IP: " -ForegroundColor Gray -NoNewLine
Write-Host "$WSL_HOST_IP" -ForegroundColor Green
Write-Host

$script_path = Split-Path $MyInvocation.MyCommand.Path -Parent
$generated_file = "$script_path/.generated"
if (Test-Path -Path $generated_file -PathType Leaf) {
  Get-Content -Path $generated_file | ForEach-Object {
    $match = $_ -match '(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d+)'
    if ($match) {
      $listen_address = $Matches[1]
      $listen_port = $Matches[2]
      netsh interface portproxy delete v4tov4 listenaddress=$listen_address listenport=$listen_port | Out-Null
    }
  }
}

'' | Out-File $generated_file

netsh interface portproxy set v4tov4 listenport=8081 listenaddress=127.0.0.1 connectport=8081 connectaddress=$WSL_IP | Out-Null
"127.0.0.1 8081" | Out-File $generated_file -Append
netsh interface portproxy set v4tov4 listenport=5037 listenaddress=127.0.0.1 connectport=5037 connectaddress=$WSL_IP | Out-Null
"127.0.0.1 5037" | Out-File $generated_file -Append
netsh interface portproxy set v4tov4 listenport=5554 listenaddress=$WSL_HOST_IP connectport=5554 connectaddress=127.0.0.1 | Out-Null
"$WSL_HOST_IP 5554" | Out-File $generated_file -Append
netsh interface portproxy set v4tov4 listenport=5555 listenaddress=$WSL_HOST_IP connectport=5555 connectaddress=127.0.0.1 | Out-Null
"$WSL_HOST_IP 5555" | Out-File $generated_file -Append

$args | ForEach-Object {
  $external_ip=Get-NetAdapter $_ | Get-NetIPAddress | ?{ $_.AddressFamily -eq 'IPv4' } | Select -ExpandProperty IPAddress
  netsh interface portproxy add v4tov4 listenaddress=$external_ip listenport=8081 connectaddress=$WSL_IP connectport=8081
  "$external_ip 8081" | Out-File $generated_file -Append
}

Write-Host "You can now begin your development in WSL by starting Android Studio from WSL. When starting up, " -ForegroundColor Gray
Write-Host "Android Studio will start an ADB server instance if it is not running yet. However, if you only " -ForegroundColor Gray
Write-Host "want to work with command lines, you have to manually start an ADB server instance by running the" -ForegroundColor Gray
Write-Host "following command in the console" -ForegroundColor Gray
Write-Host
Write-Host "    adb -a nodaemon server start" -ForegroundColor Green
Write-Host
Write-Host "Because WSL2 does not support nested virtualization, you have to run Android emulators in " -ForegroundColor Gray
Write-Host "WSL host. By default, an Android emulator will open two ports, one for console listening on 5554, " -ForegroundColor Gray
Write-Host "and one for ADB commands listening on 5555. If you start a second instance, it will open additional " -ForegroundColor Gray
Write-Host "ports 5556 and 5557, and so on for additional emulator instances. " -ForegroundColor Gray
Write-Host
Write-Host "This script supports only one emulator instance at the moment. You may have to modify the script " -ForegroundColor Gray
Write-Host "if you want to run multiple emulator instances in WSL host. " -ForegroundColor Gray
Write-Host
Write-Host "After the emulator is started, you can run" -ForegroundColor Gray
Write-Host
Write-Host "    adb connect ${WSL_HOST_IP}:5555" -ForegroundColor Green
Write-Host
Write-Host "in WSL to add the emulator to the running ADB server. That makes the emulator available for" -ForegroundColor Gray
Write-Host "Android Studio to build and deploy apps from WSL. You may have to accept USB debugging request" -ForegroundColor Gray
Write-Host "showing in the emulator for a successful connection. " -ForegroundColor Gray
Write-Host
