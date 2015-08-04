## Authenticating with a Certificate and Private Key

### Set-Up
1. Register a web application in the Azure portal. Note it's client id.
2. Generate a self-issued certificate with key length >= 2048. Using the Windows makecert.exe utility, this can be done with:

   ```
   makecert -r -pe -n "CN=Name of Certificate" -b 07/01/2015 -e 07/01/2017 -ss my -len 2048
   ```
3. Export the certificate from Certificate Manager to a file.
4. Get the base 64 thumbprint, base 64 value and key id from the certificate. With Windows powershell, this can be done with:

   ```
   $cer = New-Object System.Security.Cryptograph.X509Certificates.X509Certificate2
   $cer.Import(".\path\to\cert\from\step3.cer")
   $base64thumbprint = [System.Convert]::ToBase64String($cer.GetRawCertData())
   $base64value = [System.Convert]::ToBase64String($cer.GetRawCertData())
   $keyId = [System.Guid]::NewGuid().ToString()
   ```
5. Download the manifest for the registered web application, add the following entry to the keyCredentials array and reupload it:

   ```
   {
     "customKeyIdentifier": "[base 64 thumbprint]",
     "keyId": "[key id]",
     "type": "AsymmetricX509Cert",
     "usage": "Verify",
     "value": "[base 64 value]"
   }
   ```
6. Export the certificate as a PFX (PKCS12). This can be done via the Windows Certificate Manager GUI.
7. Fill in your tenant, client id of the web application and path and password to your .pfx file in app.rb.

### Run
Run the app as ```ruby app.rb```.

## Common problems
### I get an error that looks like: 
```
...net/http.rb:xxx: in connect SSL_connect returned=1 errno=0 state=SSLv3 read server certificate verify failed (OpenSSL::SSL::SSLError)
```
This is likely because you are on a Windows system and installed a Ruby installation that ships OpenSSL with no certificate authorities. The most common offender is RailsInstaller. [Solution](https://gist.github.com/fnichol/867550).
