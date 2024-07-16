using Azure.Data.Tables;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Remanufacturing.ProductionScheduleFacade.Services;

TableServiceClient tableServiceClient = new(Environment.GetEnvironmentVariable("TableConnectionString")!);
TableClient tableClient = tableServiceClient.GetTableClient(Environment.GetEnvironmentVariable("ProductionScheduleTableName")!);


IHost host = new HostBuilder()
	.ConfigureFunctionsWebApplication()
	.ConfigureServices(services =>
	{
		services.AddApplicationInsightsTelemetryWorkerService();
		services.ConfigureFunctionsApplicationInsights();
		services.AddSingleton(new ProductionScheduleFacadeServices(tableClient));
	})
	.Build();

host.Run();