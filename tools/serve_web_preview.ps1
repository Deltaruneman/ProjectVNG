param([string]$Root,[int]$Port=8806)
$basePath=[IO.Path]::GetFullPath($Root)
$listener=[Net.HttpListener]::new()
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()
while($listener.IsListening){
 $ctx=$listener.GetContext()
 try {
  $relative=[Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
  if(!$relative){$relative='index.html'}
  $path=[IO.Path]::GetFullPath((Join-Path $basePath $relative))
  if(!$path.StartsWith($basePath+[IO.Path]::DirectorySeparatorChar) -or !(Test-Path -LiteralPath $path -PathType Leaf)){$ctx.Response.StatusCode=404;continue}
  $mime=switch([IO.Path]::GetExtension($path)){'.html'{'text/html; charset=utf-8'} '.js'{'application/javascript'} '.wasm'{'application/wasm'} '.png'{'image/png'} default{'application/octet-stream'}}
  $ctx.Response.ContentType=$mime
  $ctx.Response.Headers.Add('Cache-Control','no-store')
  $file=[IO.File]::OpenRead($path)
  $ctx.Response.ContentLength64=$file.Length
  $file.CopyTo($ctx.Response.OutputStream)
  $file.Dispose()
 } catch {Write-Output $_.Exception.Message} finally {$ctx.Response.Close()}
}
