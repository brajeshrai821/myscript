set oShell=WScript.CreateObject("WScript.Shell")
set oArgs=WScript.Arguments
set oFileSystem=CreateObject("Scripting.fileSystemObject")
filename=oShell.ExpandEnvironmentStrings(oArgs.Item(0))
set oFile=oFileSystem.CreateTextFile(filename, true)

set oEnv=oShell.Environment("System")
oFile.WriteLine("# -- System")
for each sitem in oEnv
  a=Split(sitem,"=")
  if (UCase(a(0))<>"USERNAME") and (UCase(a(0))<>"TEMP") and (UCase(a(0))<>"TMP") then
    v=oShell.ExpandEnvironmentStrings(a(1))
    oFile.WriteLine("$ENV{'" & a(0) & "'}='" & Replace(v,"\","\\") & "';")
  end if
next
path=oEnv("PATH")

oFile.WriteLine("# -- User")
set oEnv=oShell.Environment("User")
for each sitem in oEnv
  a=Split(sitem,"=")
  if (UCase(a(0))<>"USERNAME") and (UCase(a(0))<>"TEMP") and (UCase(a(0))<>"TMP") then
    v=oShell.ExpandEnvironmentStrings(a(1))
    oFile.WriteLine("$ENV{'" & a(0) & "'}='" & Replace(v,"\","\\") & "';")
  end if
next

path=path & ";" & oEnv("PATH")
v=oShell.ExpandEnvironmentStrings(path)
oFile.WriteLine("$ENV{'PATH'}='" & v & "';")
oFile.WriteLine("1;")
oFile.Close
