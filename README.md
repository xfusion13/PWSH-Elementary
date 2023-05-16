# PWSH-Simple
Elementary powershell automation script.

## xrunas
Elementary script run runas or module pth mimikatz
### Usage
```powershell
xrunas -d essos.local -u khal.drogo -H 739120ebc4dd940310bc4bb5c9d37021
```
```powershell
xrunas -d essos.local -u khal.drogo -p horse
```
```powershell
xrunas -d essos.local -u khal.drogo -p horse -r powershell
```
```powershell
xrunas -d essos.local -u khal.drogo -p horse -mpath "C:\Tools\mimikatz.exe"
```
### Help
```b1
-d -- domain
-u -- username
-p -- password
-H -- NT-hash
-m -- path to mimikatz (default:mimikatz.exe)
-r -- run program (default:cmd.exe)
```
