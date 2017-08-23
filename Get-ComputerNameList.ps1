function Global:Get-ComputerNameList {
    param(
        $BaseName,
        $NamePrefix,
        $NameSuffix,
        $Amount,
        $AmountPrefix,
        $AmountSuffix,
        [switch]$LeadingZero,
        $StartAt = 1,
        $Delimiter = '-'
    )
    $ComputerList = @()
    $StopAt = ($Amount + $StartAt)
    for ($i=$StartAt;$i -lt $StopAt;$i++) {
        $num = $i
        if ($i -lt 10 -and $LeadingZero.IsPresent) {
            $num = "0$i"
        }
        $ComputerList += @($NamePrefix,$BaseName,$NameSuffix,$Delimiter,$AmountPrefix,$num,$AmountSuffix) -join ''
    }
    return $ComputerList
}
