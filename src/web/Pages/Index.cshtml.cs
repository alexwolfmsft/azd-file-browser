using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace FileBrowser.Pages;

public class IndexModel : PageModel
{
    private readonly ILogger<IndexModel> _logger;
    private readonly BlobServiceClient _blobService;
    public List<string> Files { get; set; } = new List<string>();

    public IndexModel(ILogger<IndexModel> logger, BlobServiceClient blobService)
    {
        _logger = logger;
        _blobService = blobService;
    }

    public async Task OnGet()
    {
        await foreach (BlobItem blobItem in _blobService.GetBlobContainerClient("images").GetBlobsAsync())
        {
            Files.Add(blobItem.Name);
        }
    }
}
