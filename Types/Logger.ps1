Add-type -TypeDefinition @"

using System.Collections;
using System;

public class Logger {

	public System.Collections.ArrayList Entries;
	public int    Count;
	public int    MaxLines;
	public string LogFile;
	public bool   prefixDate;

	public Logger(){
		Entries = new System.Collections.ArrayList();
		Count = 0;
		MaxLines = 5;
		LogFile = "";
		prefixDate = false;
	}

	public void Add(string str)
	{
		if (prefixDate)
		{
			str = string.Format("[{0}] {1}",DateTime.Now.ToString("yyyy-MM-dd HH':'mm':'ss':'ffff"), str);
		}
		Entries.Add(str);
		Count++;
		if (Count >= MaxLines)
		{
			AppendLog();
		}
	}

	private void AppendLog()
	{
		if (LogFile != "")
		{
			using (System.IO.StreamWriter file = new System.IO.StreamWriter(LogFile, true))
			{
				foreach (string entry in Entries)
				{
					file.WriteLine(entry);
				}
			}
			Entries.Clear();
			Count = 0;
		}
	}

	public void Flush()
	{
		AppendLog();
	}

	public void setLogFile(string file)
	{
		LogFile = file;
	}

	public void setMaxLines(int max)
	{
		MaxLines = max;
	}
}
"@


<#

Example usage:

PS C:\> $logger = new-object logger
PS C:\> $logger |ft -auto

Entries Count MaxLines LogFile
------- ----- -------- -------
{}          0        5


PS C:\> $logger.setMaxLines(10)
PS C:\> $logger |ft -auto

Entries Count MaxLines LogFile
------- ----- -------- -------
{}          0       10


PS C:\> (1..9) |% { $logger.Add("$_") }
PS C:\> $logger |ft -auto

Entries         Count MaxLines LogFile
-------         ----- -------- -------
{1, 2, 3, 4...}     9       10


PS C:\> $logger.setLogFile("C:\temp\log02.log")
PS C:\> $logger.Add("end")
PS C:\> $logger |ft -auto

Entries Count MaxLines LogFile
------- ----- -------- -------
{}          0       10 C:\temp\log02.log


PS C:\> gc $logger.LogFile
1
2
3
4
5
6
7
8
9
end
PS C:\>

#>
