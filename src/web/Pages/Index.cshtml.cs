using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace FileBrowser.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    private readonly BlobServiceClient _blobService;
    public List<BlobItem> Files { get; set; } = new List<BlobItem>();
    public string ContainerURI = string.Empty;

    public IndexModel(ILogger<IndexModel> logger, BlobServiceClient blobService)
    {
        _logger = logger;
        _blobService = blobService;
    }

    public async Task OnGet()
    {
        var blobClient = _blobService.GetBlobContainerClient("demofiles");

        ContainerURI = blobClient.Uri.AbsoluteUri;
        
        await foreach (BlobItem blobItem in blobClient.GetBlobsAsync())
        {
            Files.Add(blobItem);
        }
    }
}