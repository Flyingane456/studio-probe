# Installs the Studio bridge plugin, links 127.0.0.1:58741 to the home Mac over Tailscale, restarts Studio.
$dir = "$env:LOCALAPPDATA\Roblox\Plugins"
New-Item -ItemType Directory -Force $dir | Out-Null
Invoke-WebRequest "https://raw.githubusercontent.com/Flyingane456/studio-probe/main/studio/MCPPlugin.rbxmx" -OutFile "$dir\MCPPlugin.rbxmx" -UseBasicParsing
Start-Service iphlpsvc -ErrorAction SilentlyContinue
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=58741 connectaddress=100.98.217.70 connectport=58741
try { "bridge health: " + (Invoke-WebRequest http://127.0.0.1:58741/health -UseBasicParsing -TimeoutSec 10).StatusCode } catch { "bridge not reachable: $($_.Exception.Message)" }
$exe = Get-ChildItem "$env:LOCALAPPDATA\Roblox\Versions" -Recurse -Filter RobloxStudioBeta.exe -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2
if ($exe) { Start-Process $exe.FullName; "studio restarted" } else { "studio exe not found" }
