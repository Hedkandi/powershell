$code = @"
    private enum WTS_INFO_CLASS
    {
        WTSInitialProgram = 0,
        WTSApplicationName = 1,
        WTSWorkingDirectory = 2,
        WTSOEMId = 3,
        WTSSessionId = 4,
        WTSUserName = 5,
        WTSWinStationName = 6,
        WTSDomainName = 7,
        WTSConnectState = 8,
        WTSClientBuildNumber = 9,
        WTSClientName = 10,
        WTSClientDirectory = 11,
        WTSClientProductId = 12,
        WTSClientHardwareId = 13,
        WTSClientAddress = 14,
        WTSClientDisplay = 15,
        WTSClientProtocolType = 16,
        WTSIdleTime = 17,
        WTSLogonTime = 18,
        WTSIncomingBytes = 19,
        WTSOutgoingBytes = 20,
        WTSIncomingFrames = 21,
        WTSOutgoingFrames = 22,
        WTSClientInfo = 23,
        WTSSessionInfo = 24,
        WTSSessionInfoEx = 25,
        WTSConfigInfo = 26,
        WTSValidationInfo = 27,
        WTSSessionAddressV4 = 28,
        WTSIsRemoteSession = 29
    }
    public static String GetActiveConsoleUsername()
    {
        uint result = WTSGetActiveConsoleSessionId();
        if (result != 0xFFFFFFFF) {
            return GetUsernameBySessionId(result);
        }
        else {
            return "";
        }
    }
    public static String GetUsernameBySessionId(uint sessionId)
    {
        IntPtr buffer;
        uint strLen;
        var username = "SYSTEM"; // assume SYSTEM as this will return "\0" below
        if (WTSQuerySessionInformation(IntPtr.Zero, sessionId, WTS_INFO_CLASS.WTSUserName, out buffer, out strLen) && strLen > 1)
        {
            username = Marshal.PtrToStringAnsi(buffer); // don't need length as these are null terminated strings
            WTSFreeMemory(buffer);
            if (WTSQuerySessionInformation(IntPtr.Zero, sessionId, WTS_INFO_CLASS.WTSDomainName, out buffer, out strLen) && strLen > 1)
            {
                username = Marshal.PtrToStringAnsi(buffer) + "\\" + username; // prepend domain name
                WTSFreeMemory(buffer);
            }
        }
        return username;
    }

    //Function to run a process as active user from windows service
    [DllImport("Wtsapi32.dll", SetLastError = true)]
    static extern bool WTSQuerySessionInformation(
        IntPtr hServer,
        uint sessionId,
        WTS_INFO_CLASS wtsInfoClass,
        out IntPtr ppBuffer,
        out uint pBytesReturned
    );

    [DllImport("kernel32.dll")]
    private static extern uint WTSGetActiveConsoleSessionId();

    [DllImport("Wtsapi32.dll")]
    private static extern void WTSFreeMemory(IntPtr pointer);
"@

add-type -MemberDefinition $code -Name 'User' -Namespace 'PS'
[PS.User]::GetActiveConsoleUsername()
