# Remove-PythonCache.ps1
# Script to recursively remove Python cache files and directories

Write-Host "Starting Python cache cleanup..." -ForegroundColor Green

# Define the types of Python cache files/directories to remove
$cachePatterns = @(
    "*.pyc",
    "*.pyo",
    #"*.pyd",
    "__pycache__"
    #"*.so",
    #"*.egg-info",
    #"*.egg",
    #".pytest_cache",
    #".coverage",
    #"htmlcov",
    #".tox",
    #".eggs",
    #"*.ipynb_checkpoints",
    #"build",
    #"dist"
)

# Get the current directory as the starting point
$startDir = Get-Location

# Initialize counters
$filesRemoved = 0
$dirsRemoved = 0

foreach ($pattern in $cachePatterns) {
    # Handle directory vs file patterns differently
    if ($pattern -like "*.*") {
        # File pattern
        $cacheFiles = Get-ChildItem -Path $startDir -Filter $pattern -Recurse -File -ErrorAction SilentlyContinue
        foreach ($file in $cacheFiles) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Removed file: $($file.FullName)" -ForegroundColor Yellow
            $filesRemoved++
        }
    } else {
        # Directory pattern
        $cacheDirs = Get-ChildItem -Path $startDir -Filter $pattern -Recurse -Directory -ErrorAction SilentlyContinue
        foreach ($dir in $cacheDirs) {
            Remove-Item -Path $dir.FullName -Recurse -Force
            Write-Host "Removed directory: $($dir.FullName)" -ForegroundColor Cyan
            $dirsRemoved++
        }
    }
}

Write-Host "`nCleanup completed!" -ForegroundColor Green
Write-Host "Removed $filesRemoved files and $dirsRemoved directories." -ForegroundColor Green
