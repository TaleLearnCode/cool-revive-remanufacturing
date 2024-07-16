using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Remanufacturing.ProductionScheduleFacade.Services;
using Remanufacturing.Responses;
using System.Net;

namespace Remanufacturing.ProductionScheduleFacade.Functions;

public class GetNextCore(ILogger<GetNextCore> logger, ProductionScheduleFacadeServices productionScheduleFacadeServices)
{

	private readonly ILogger<GetNextCore> _logger = logger;
	private readonly ProductionScheduleFacadeServices _productionScheduleFacadeServices = productionScheduleFacadeServices;

	[Function("GetNextCore")]
	public async Task<IActionResult> RunAsync([HttpTrigger(AuthorizationLevel.Function, "get", Route = "{podId}/{date}")] HttpRequest request,
		string podId,
		string date)
	{

		IResponse response;

		try
		{
			_logger.LogInformation("Getting the next core on the production schedule.");
			response = await _productionScheduleFacadeServices.GetNextCoreAsync(podId, date, request.HttpContext.TraceIdentifier);
		}
		catch (Exception ex)
		{
			response = new Remanufacturing.Responses.ProblemDetails()
			{
				Type = "https://httpstatuses.com/500", // HACK: In a real-world scenario, you would want to provide a more-specific URI reference that identifies the response type.
				Title = "An error occurred while retrieving the next core on the production schedule.",
				Status = HttpStatusCode.InternalServerError,
				Detail = ex.Message, // HACK: In a real-world scenario, you would not want to expose the exception message to the client.
				Instance = request.HttpContext.TraceIdentifier
			};
		}

		if (response is StandardResponse standardResponse)
		{
			return new OkObjectResult(standardResponse);
		}
		else
		{
			return new ObjectResult(response)
			{
				StatusCode = (int)HttpStatusCode.OK
			};
		}
	}

}