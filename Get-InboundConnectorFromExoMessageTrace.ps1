[cmdletbinding()]
Param
(
    [string]$Sender,
    [string]$Recipient,
    [string]$Subject,
    [ValidateSet("contains", "startswith", "endswith")]
    $SubjectFilterType

)

if ($Subject -and -Not $SubjectFilterType)
{
    Write-Warning -Message "If you use the 'Subject' parameter, please also specify 'SubjectFilterType'"
    Exit
}

# Initialize parameter hashtable
$ValidParameters = @{}

# Add only parameters specified by the user to the Validparameters Hashtable
foreach ($Entry in $PSBoundParameters.GetEnumerator())
{
    # Add the propertyname and it's value to the hashtable
    $ValidParameters.Add($Entry.Key,$Entry.Value)
}

$TraceDetail = Get-EOMessageTraceV2 @ValidParameters | Get-EOMessageTraceDetailV2 -Event Receive

if ($TraceDetail)
{
    $ConnectorData = $TraceDetail.data.split(";") | ? {$_ -match "InboundConnectorData"}

    if ($ConnectorData)
    {
        $Name = $ConnectorData.Replace("'S:","").Split("=")[-1]
        Write-Host -ForegroundColor Green -Object "`nUsed Inbound Connector Name is: $($Name).`n"
    }

    Else
    {
        Write-Warning -Message "No specific connector data was found."
    }
}

Else
{
    Write-Warning -Message "No Events with the specified criteria were found."
}