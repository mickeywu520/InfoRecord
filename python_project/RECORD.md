## if you wanna source the venv in powershell(Windows), and got error, please execute below command first, till you exit the terminal.
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\myvenv\Scripts\Activate.ps1
```
## allow the current user to execute
```
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
.\myvenv\Scripts\Activate.ps1
```
## For VS code terminal, in file of ".vscode/settings.json", add below command
```
{
    "terminal.integrated.shellArgs.windows": ["-ExecutionPolicy", "Bypass"]
}
```



