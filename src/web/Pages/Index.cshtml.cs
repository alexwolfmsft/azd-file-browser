using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

namespace FileManager.Pages;

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

    [BindProperty]
    public IFormFile Upload { get; set; }
    public async Task<IActionResult> OnPostAsync()
    {
        var blobClient = _blobService.GetBlobContainerClient("demofiles");

        await blobClient.UploadBlobAsync(Upload.FileName, Upload.OpenReadStream());

        return RedirectToAction("OnGet");
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