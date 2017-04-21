$Path = "C:\windows\system32\test.txt"
[IO.Path]::GetExtension($Path)
[IO.Path]::GetDirectoryName($Path)
[IO.Path]::GetFileName($Path)
[IO.Path]::GetFileNameWithoutExtension($Path)
[IO.Path]::GetInvalidFileNameChars() -join "-"
[IO.Path]::GetInvalidPathChars() -join "-"
[IO.Path]::GetPathRoot($Path)
[IO.Path]::GetRandomFileName()
[IO.Path]::GetTempFileName()
[IO.Path]::HasExtension($Path)
[IO.Path]::IsPathRooted($Path)
