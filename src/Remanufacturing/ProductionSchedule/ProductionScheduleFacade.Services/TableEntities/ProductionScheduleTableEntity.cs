#nullable disable

using Azure;
using Azure.Data.Tables;

namespace Remanufacturing.ProductionScheduleFacade.TableEntities;

public class ProductionScheduleTableEntity : ITableEntity
{

	public string PodId { get; set; } = null!;
	public string Date { get; set; }
	public string Sequence { get; set; }
	public string Model { get; set; } = null!;
	public string CoreId { get; set; } = null!;
	public string FinishedProductId { get; set; } = null!;
	public string Status { get; set; } = null!;


	public string PartitionKey { get; set; } = null!;
	public string RowKey { get; set; } = null!;
	public DateTimeOffset? Timestamp { get; set; }
	public ETag ETag { get; set; }

}