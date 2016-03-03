function Test-SystemResponseTime
{
<#
.Synopsis
   Get ping latency for each system.
.DESCRIPTION
   The system provided is pinged 4 times and the results are returned in the form
   of the minimum, maximum and average latency. Additionally, if the system was 
   unreachable, a flag of ResourceAvailable = 'False' is set. For resources which
   are unavailable, the minimum, maximum and average latency is set to a default
   9999.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string[]] $ComputerName
    )

    Begin
    {
    }
    Process
    {
        foreach ($Computer in $ComputerName)
        {
            write-progress -activity "Checking System Latency..." -CurrentOperation "Checking $Computer..." -status "Please wait."

            # Create the object which will be returned.
            $Result = new-object PSObject -Property @{
                ComputerName      = $Computer
                AverageLatency    = 0
                MinimumLatency    = 0
                MaximumLatency    = 0
                ResourceAvailable = $True
            }

            try
            {
                $ConnectionTest = Test-Connection $Computer -ea Stop
            }
            catch
            {
                $Result.ResourceAvailable = $False
                $Result.AverageLatency    = 9999
                $Result.MinimumLatency    = 9999
                $Result.MaximumLatency    = 9999
                Continue
            }

            $Measurements = $ConnectionTest | Measure-Object -Property "ResponseTime" -Average -min -max
            
            $Result.AverageLatency    = $Measurements.Average
            $Result.MinimumLatency    = $Measurements.Minimum
            $Result.MaximumLatency    = $Measurements.Maximum
            
            Write-Output $Result
        }
    }
    End
    {
    }
}