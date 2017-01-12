# Source: 
# https://social.technet.microsoft.com/Forums/exchange/en-US/07558d3c-4cb7-4ece-868f-b8a6ac9d3ace/cryptunprotectdata-from-powershell?forum=winserverpowershell
# Modified to be able to generate hashes which can be used with rdp-files used in mstsc.exe
# Changes (http://www.remkoweijnen.nl/blog/2008/03/02/how-rdp-passwords-are-encrypted-2/)
# Also the description for RDP-passwords should always be "psw" (http://www.remkoweijnen.nl/blog/2007/10/18/how-rdp-passwords-are-encrypted/=

function Get-RDPPasswordHash {
    param(
        [string]$Password
    )
$dllimport = '[StructLayout ( LayoutKind.Sequential, CharSet = CharSet.Unicode )]
	public struct DATA_BLOB
	{
		public int cbData;
		public IntPtr pbData;
	}

	[DllImport ( "crypt32.dll", SetLastError = true,
	CharSet = System.Runtime.InteropServices.CharSet.Auto )]
	public static extern bool CryptProtectData (
	ref DATA_BLOB pPlainText,
	[MarshalAs ( UnmanagedType.LPWStr )]string szDescription,
	IntPtr pEntroy,
	IntPtr pReserved,
	IntPtr pPrompt,
	int dwFlags,
	ref DATA_BLOB pCipherText );'
			
	#Add the definitions
	try{
	$type = Add-Type -MemberDefinition $dllimport -Name Win32Utils -Namespace CryptProtectData -UsingNamespace System.Text -PassThru -IgnoreWarnings
	}catch{}
	

	$passToEncrypt = [System.Text.Encoding]::Unicode.GetBytes($Password)

	
	#Setup the dllImport Vars
	$dataIn = New-Object CryptProtectData.Win32Utils+DATA_BLOB
	$dataout =  New-Object CryptProtectData.Win32Utils+DATA_BLOB
	$nullptr = [IntPtr]::Zero

	#Initialise the dataIn variable , add extra checks here if we cant allocate
	$dataIn.pbData = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(512)
	$dataIn.cbData = 512
	[System.Runtime.InteropServices.Marshal]::Copy($passToEncrypt,0,$dataIn.pbData,$passToEncrypt.Length)

	#Try and encrypt the data 
	$success = $type[0]::CryptProtectData([ref] $dataIn,"psw",$nullptr,$nullptr,$nullptr,0x1,[ref] $dataout)
	write-host "Password Encrypted $success"

	if($success)
	{
		$encryptedBytes = New-Object byte[] $dataout.cbData
		[System.Runtime.InteropServices.Marshal]::Copy($dataOut.pbData,$encryptedBytes,0,$dataout.cbData)
		$encryptedByteString = [BitConverter]::ToString($encryptedBytes).replace("-","")

		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($dataIn.pbData)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($dataout.pbData)
		
        $encryptedByteString += "0"

        Write-Output $encryptedByteString
	}
	else
	{
		[System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
	}

}
