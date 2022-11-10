# How to run the completed project

## Prerequisites

To run the script in this folder, you need the following:

- The [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/powershell/microsoftgraph/installation) installed on your development machine. (**Note:** This tutorial was written with PowerShell 7.2.2 and Microsoft Graph PowerShell SDK version 1.9.5. The steps in this guide may work with other versions, but that has not been tested.)
- A Microsoft work or school account with the **Global administrator** role.

If you don't have a Microsoft account, you can [sign up for the Microsoft 365 Developer Program](https://developer.microsoft.com/microsoft-365/dev-program) to get a free Microsoft 365 subscription.

## Register an application

1. Open a browser and navigate to the [Azure Active Directory admin center](https://aad.portal.azure.com) and login using a Global administrator account.

1. Select **Azure Active Directory** in the left-hand navigation, then select **App registrations** under **Manage**.

1. Select **New registration**. Enter a name for your application, for example, `PowerShell Graph Tutorial`.

1. Set **Supported account types** to **Accounts in this organizational directory only**.

1. Leave **Redirect URI** empty.

1. Select **Register**. On the application's **Overview** page, copy the value of the **Application (client) ID** and **Directory (tenant) ID** and save them, you will need these values in the next step.

### Create a self-signed certificate

The Microsoft Graph PowerShell SDK requires a certificate for app-only authentication. For development purposes, a self-signed certificate is sufficient. You need a certificate with the private key installed on the local machine, and the public key exported in a .CER, .PEM, or .CRT file.

#### Windows

On Windows, you can use the [pki PowerShell module](https://docs.microsoft.com/powershell/module/pki) to generate the certificate.

```powershell
$cert = New-SelfSignedCertificate -Subject "CN=PowerShell App-Only" -CertStoreLocation `
  "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 `
  -KeyAlgorithm RSA -HashAlgorithm SHA256
Export-Certificate -Cert $cert -FilePath "./PowerShellAppOnly.cer"
```

#### Linux/MacOS

On Linux or MacOS, you can use [OpenSSL](https://www.openssl.org/) to generate the private and public keys, then use PowerShell to install the private key into a certificate store readable by PowerShell.

1. Generate a new X509 certificate using the following command.

    ```bash
    openssl req -x509 -newkey rsa:2048 -sha256 -days 365 -keyout powershell.pem -out powershell.crt -subj "/CN=PowerShell App-Only"
    ```

1. OpenSSL prompts you for a PEM pass phrase. Enter a pass phrase you will remember.

1. Create a PFX file using the following command.

    ```bash
    openssl pkcs12 -export -out powershell.pfx -inkey powershell.pem -in powershell.crt
    ```

1. OpenSSL prompts you for the pass phrase for **powershell.pem**, enter the pass phrase you used in the previous step.

1. OpenSSL prompts you for an export password. Enter a password you will remember.

1. Open PowerShell and run the following commands, replacing *&lt;export-password&gt;* with the export password you used in the previous step.

    ```powershell
    using namespace System.Security.Cryptography.X509Certificates
    $store = [X509Store]::new('My', 'CurrentUser', 'ReadWrite')
    $store.Add([X509Certificate2]::new('./powershell.pfx', '<export-password>', [X509KeyStorageFlags]::PersistKeyS
    et))
    $store.Dispose()
    ```

### Update the app registration

1. In the AAD Admin Center, select **API permissions** under **Manage**.

1. Remove the default **User.Read** permission under **Configured permissions** by selecting the ellipses (**...**) in its row and selecting **Remove permission**.

1. Select **Add a permission**, then **Microsoft Graph**.

1. Select **Application permissions**.

1. Select **User.Read.All**, then select **Add permissions**.

1. Select **Grant admin consent for...**, then select **Yes** to provide admin consent for the selected permission.

1. Select **Certificates and secrets** under **Manage**, then select **Certificates**.

1. Select **Upload certificate**. Upload the **PowerShellAppOnly.cer** or **powershell.crt** file you created in the previous step, then select **Add**.

## Configure the sample

1. Open [settings.json](./graphtutorial/settings.json) and update the values according to the following table.

    | Setting | Value |
    |---------|-------|
    | `clientId` | The client ID of your app registration |
    | `clientCertificate` | The subject of the certificate generated in [Create a self-signed certificate](#create-a-self-signed-certificate). For example, `CN=PowerShell App-Only`. |
    | `tenantId` | The tenant ID of your organization |

## Run the sample

In PowerShell, navigate to the project directory and run the following command.

```Shell
./GraphTutorialAppOnly.ps1
```

**Note:** The scripts included in this sample are not digitally signed. Attempting to run them may result in the following error:

```powershell
.\GraphTutorialAppOnly.ps1: File C:\Source\GraphTutorialAppOnly.ps1 cannot be loaded. The file C:\Source\GraphTutorialAppOnly.ps1 is not digitally signed. You cannot run this script on the current system. For more information about running scripts and setting execution policy, see about_Execution_Policies at https://go.microsoft.com/fwlink/?LinkID=135170.
```

If you get this error, use the following commands to unblock the file and temporarily allow unsigned scripts in the current PowerShell session. This will not change the default execution policy, the setting is only effective in the current session.

```powershell
Unblock-File .\GraphTutorialAppOnly.ps1
Set-ExecutionPolicy Unrestricted -Scope Process
```
