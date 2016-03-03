Add-Type -TypeDefinition @"
	using System;
	public class TestFiles3
	{
		private string OneMB = new string('X', (1024 * 1024));
		public void CreateFileWithSizeInMB(int size, string FilePath)
		{
			using (System.IO.StreamWriter file = new System.IO.StreamWriter(FilePath, true))
			{
				for (int i = 0; i < size; i++)
				{
					file.Write(OneMB);
				}
			}
		}

		private string OneKB = new string('X', (1024));
		public void CreateFileWithSizeInKB(int size, string FilePath)
		{
			using (System.IO.StreamWriter file = new System.IO.StreamWriter(FilePath, true))
			{
				for (int i = 0; i < size; i++)
				{
					file.Write(OneKB);
				}
			}
		}
	}
"@



<###########################
 Example usage:

 $tf = new-object TestFiles
 $tf.CreateFileWithSizeInMB(12,"c:\users\glaisne\desktop\12MB.txt")

###########################>
