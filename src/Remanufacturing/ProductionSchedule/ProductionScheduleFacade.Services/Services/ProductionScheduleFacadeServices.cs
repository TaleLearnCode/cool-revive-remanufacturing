using Azure.Data.Tables;
using Remanufacturing.ProductionScheduleFacade.TableEntities;
using Remanufacturing.Responses;
using System.Globalization;
using System.Net;

namespace Remanufacturing.ProductionScheduleFacade.Services;

public class ProductionScheduleFacadeServices(TableClient tableClient)
{

	private readonly TableClient _tableClient = tableClient;

	public async Task<IResponse> GetNextCoreAsync(string podId, string date, string instance)
	{
		try
		{

			ArgumentException.ThrowIfNullOrWhiteSpace(podId, nameof(podId));
			if (!DateTime.TryParseExact(date, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out _))
				throw new ArgumentException("The date is not in the correct format.", nameof(date));

			List<ProductionScheduleTableEntity> productionSchedule = [.. _tableClient.Query<ProductionScheduleTableEntity>(x => x.PartitionKey == $"{podId}_{date}")];
			productionSchedule.Sort((x, y) => x.Sequence.CompareTo(y.Sequence));

			ProductionScheduleTableEntity? nextCore = productionSchedule.Where(x => x.Status == "Scheduled").FirstOrDefault();
			if (nextCore is not null)
			{

				nextCore.Status = "In Production";
				nextCore.ETag = new Azure.ETag("*");
				await _tableClient.UpdateEntityAsync(nextCore, nextCore.ETag);

				return new StandardResponse()
				{
					Type = "https://httpstatuses.com/200", // HACK: In a real-world scenario, you would want to provide a more-specific URI reference that identifies the response type.
					Title = "Next core on the production schedule retrieved successfully.",
					Status = HttpStatusCode.OK,
					Detail = "Next core on the production schedule retrieved successfully.",
					Instance = instance,
					Extensions = new Dictionary<string, object>()
					{
						{ "PodId", nextCore.PodId },
						{ "Date", nextCore.Date },
						{ "Sequence", nextCore.Sequence },
						{ "Model", nextCore.Model },
						{ "CoreId", nextCore.CoreId },
						{ "FinishedProductId", nextCore.FinishedProductId }
					}
				};
			}
			else
			{
				return new ProblemDetails()
				{
					Type = "https://httpstatuses.com/204", // HACK: In a real-world scenario, you would want to provide a more-specific URI reference that identifies the response type.
					Title = "No (more) cores are scheduled for production on the specified date.",
					Status = HttpStatusCode.NoContent,
					Detail = "No (more) cores are scheduled for production on the specified date.",
					Instance = instance
				};
			}
		}
		catch (ArgumentException ex)
		{
			return new ProblemDetails(ex, instance);
		}
		catch (Exception ex)
		{
			return new ProblemDetails()
			{
				Type = "https://httpstatuses.com/500", // HACK: In a real-world scenario, you would want to provide a more-specific URI reference that identifies the response type.
				Title = "An error occurred while retrieving the next core on the production schedule.",
				Status = HttpStatusCode.InternalServerError,
				Detail = ex.Message, // HACK: In a real-world scenario, you would not want to expose the exception message to the client.
				Instance = instance
			};
		}
	}

}