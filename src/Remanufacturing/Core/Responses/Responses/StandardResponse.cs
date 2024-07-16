using System.Net;

namespace Remanufacturing.Responses;

/// <summary>
/// Represents the standard response for an HTTP endpoint derived from RFC 7807.
/// </summary>
public class StandardResponse : IResponse
{

	/// <summary>
	/// A URI reference that identifies the response type. This specification encourages that, when dereferenced, it provide human-readable documentation for the response type.
	/// </summary>
	public string Type { get; set; } = null!;

	/// <summary>
	/// A short, human-readable summary of the response. It SHOULD NOT change from occurrence to occurrence of the response type, except for purposes of localization.
	/// </summary>
	public string Title { get; set; } = null!;

	/// <summary>
	/// The HTTP status code for the response.
	/// </summary>
	public HttpStatusCode Status { get; set; } = HttpStatusCode.OK;

	/// <summary>
	/// A human-readable explanation specific to this occurrence of the response.
	/// </summary>
	public string? Detail { get; set; }

	/// <summary>
	/// A URI reference that identifies the specific occurrence of the response. It may or may not yield further information if dereferenced.
	/// </summary>
	public string? Instance { get; set; }

	/// <summary>
	/// Additional details about the response that may be helpful when receiving the response.
	/// </summary>
	public Dictionary<string, object>? Extensions { get; set; }

}